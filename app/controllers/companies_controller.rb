class CompaniesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:show, :edit, :update, :destroy]
  before_filter :authorize, only: [:edit, :update, :destroy]

  def new
    if current_user && current_user.god?
      @user = current_user
      @company = @user.companies.build
      @verticals = Vertical.all
      redirect_to signup_url(subdomain: false) if !request.subdomain.empty?
    else
      return redirect_to root_url
    end
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

    @company.instagram_location_id = get_instagram_location_id(@company.instagram_location_id) if @company.instagram_location_id.length > 12

    if @company.save
      save_verticals(@verticals, @company) if @verticals
      cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all} if @user.admin?
      # Content is imported from provider via a Company commit callback
      redirect_to posts_url(subdomain: @company.subdomain)
    else
      render "new"
    end
  end

  def show
    @has_company_logo = true
    @posts = @company.posts.where(published:true).order("provider_publication_date DESC").paginate(:page => params[:page], per_page:8)
    @referrer = referrer
    @has_current_user_already_joined = current_user && current_user.talent? && current_user.member_of?(@company.id)
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
    @verticals = @company.verticals.map(&:id)
    @submit_button_text = "Save"
  end

  def update
    if params[:commit] == "update_show_in_index"
      current_company.update_attribute(:show_in_index, params[:company][:show_in_index]) if current_user.god?
      return render :nothing => true
    end

    @notice = nil
    @company.assign_attributes params[:company]
    @verticals = params[:verticals] || []
    @verticals = @verticals.map{|x| x.to_i }

    @company.instagram_location_id = get_instagram_location_id(@company.instagram_location_id) if @company.instagram_location_id.length > 12

    if @company.save
      save_verticals(@verticals, @company)
      @notice = "Profile Updated"
      redirect_to dashboard_url, notice: @notice
    else
      @submit_button_text = "Save" if current_user && current_user.god_or_admin?
      render 'edit'
    end
  end

  def destroy
    return if !current_user.god?
    company_name = current_company.name
    current_company.destroy
    redirect_to companies_url(subdomain:false), notice:"#{company_name} destroyed"
  end

  def get_instagram_location_id(foursquare_v2_id)
    data = HTTParty.get("https://api.instagram.com/v1/locations/search?foursquare_v2_id=#{foursquare_v2_id}",
    :query=>{access_token:Settings.tokens.instagram})
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
    @company = current_company
  end

  def choose_layout
    if action_name == "show" && referrer == "external" #Test if coming from non-innercircle host or directly typing in url
      'onboarding'
    elsif ['create'].include?(action_name) && !(current_user && current_user.god_or_admin?)
      'onboarding'
    else
      'application'
    end
  end
end
