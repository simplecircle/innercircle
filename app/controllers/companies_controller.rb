class CompaniesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:show]

  def new
    if current_user && current_user.god?
      @user = current_user
      @company = @user.companies.build
    else
      @company = Company.new
      @user = @company.users.build
      @profile = @user.build_profile
    end
    @verticals = Vertical.all
    redirect_to signup_url(subdomain: false) if !request.subdomain.empty?
  end

  def create
    @company = Company.new(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    @verticals = (params[:verticals] || []).map{|v| v.to_i}

    if current_user && current_user.god?
      @company.users << current_user
      @user = current_user
    else
      @user = @company.users.first
      @user.role = 'admin' if @user.role == nil
      @profile = @user.profile
    end

    @company.instagram_uid = get_instagram_id(@company.instagram_uid) if @company.instagram_uid.length > 12

    if @company.save
      save_verticals(@verticals, @company) if @verticals
      cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all} if @user.admin?
      redirect_to new_from_provider_url(subdomain: @company.subdomain)
    else
      render "new"
    end
  end

  def show
    @posts = @company.posts.where(published:true).order("provider_publication_date DESC").paginate(:page => params[:page], per_page:8)
    respond_to do |format|
      format.html {render("show")}
      format.js {render("posts/published.js.erb")}
    end
  end

  def index
    @companies = current_user.owned_companies.sort {|a, b| a.name <=> b.name}
  end

  def edit
    @mode = 'update'
    @company = Company.find_by_subdomain!(request.subdomain)
    @verticals = @company.verticals.map(&:id)
    @submit_button_text = "Save"
  end

  def update
    @notice = nil
    @company = current_user.owned_companies.find {|co| co.id == params[:id].to_i}
    @company.assign_attributes params[:company]
    @verticals = params[:verticals] || []
    @verticals = @verticals.map{|x| x.to_i }
    instagram_uid = params[:company][:instagram_uid]

    @company.instagram_uid = get_instagram_id(@company.instagram_uid) if @company.instagram_uid.length > 12

    if @company.save
      save_verticals(@verticals, @company)
      @notice = "Profile Updated"
      redirect_to dashboard_url, notice: @notice
    else
      @submit_button_text = "Save" if current_user && current_user.god_or_admin?
      render 'edit'
    end
  end


  def get_instagram_id(foursquare_v2_id)
    data = HTTParty.get("https://api.instagram.com/v1/locations/search?foursquare_v2_id=#{foursquare_v2_id}",
    :query=>{access_token:"20779015.1fb234f.30609b83744b49118a56939d1e492ffe"})
    data["data"].empty? ? foursquare_v2_id : data["data"][0]["id"]
  end

  def save_verticals(verticals, company)
    #Destroy vertical association if the user unchecked it in form
    company.verticals.each do |v|
      if !verticals.include? v.id.to_s
        CompaniesVertical.where(:company_id => company.id, :vertical_id=> v.id).destroy_all
      end
    end
    verticals.each do |v|
      CompaniesVertical.find_or_create_by_company_id_and_vertical_id(company.id, v)
    end
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end

  def choose_layout
    if ['new', 'create'].include?(action_name) && !(current_user && current_user.god_or_admin?)
      'onboarding'
    else
      'application'
    end
  end
end
