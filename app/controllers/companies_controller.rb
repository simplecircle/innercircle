class CompaniesController < ApplicationController
  include ApplicationHelper

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
    @company = Company.new(company_params)
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    @verticals = (params[:verticals] || []).map{|v| v.to_i}
    @normalized_pi = normalize_provider_identifiers(params[:company][:provider_identifier][:linkedin])

    # if current_user && current_user.god?
    #   @company.users << current_user
    #   @user = current_user
    # else
    #   @user = @company.users.first
    #   @user.role = 'admin' if @user.role == nil
    #   @profile = @user.profile
    # end

    @company.instagram_location_id = get_instagram_location_id(@company.instagram_location_id) if @company.instagram_location_id.length > 12

    if @company.save
      @normalized_pi.split(",").each do |pi|
         ProviderIdentifier.create({company_id:@company.id, linkedin:pi}) 
      end
      save_verticals(@verticals, @company) if @verticals
      # cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all} if @user.admin?

      # @company.create_default_admin_user

      redirect_to posts_url(subdomain: @company.subdomain)
    else
      render "new"
    end
  end

  def show
    @posts = @company.posts.where(published:true).order("provider_publication_date DESC").limit(Company::PAGINATION_LIMIT).offset(company_params[:offset])
    @connections = @company.connections(current_user) if current_user
    respond_to do |format|
      format.html {render("show")}
      format.js {render("posts/published.js.erb")}
    end
  end

  def index
    @verticals = Vertical.all.pluck(:name)
    if !company_params[:q].blank?
     @q = company_params[:q]
     @companies = Company.where('name ILIKE ? OR hq_city ILIKE ? OR hq_city ILIKE ?', "#{@q}%","#{@q}%","#{@q}%") 
    elsif @vertical = company_params[:vertical]
      @verticals.reject!{|v| v == @vertical.downcase}
      @verticals.unshift("All categories").sort_by!{ |v| v.downcase }
      @companies = Company.published.joins(:verticals).where("lower(verticals.name) = ?", company_params[:vertical].downcase).order('last_published_posts_at DESC')
    elsif current_user and current_user.god?
      # Company::PAGINATION_LIMIT + 1 is being returned here so paging will ACURATELY know when it's at the end of a collection.
      @companies = Company.includes(:provider_identifiers).order(:name)
      # respond_to do |format|
      #   format.html {render("index")}
      #   format.js {render("index.js.erb")}
      # end
    else
      # Company::PAGINATION_LIMIT + 1 is being returned here so paging will ACURATELY know when it's at the end of a collection.
      @companies = Company.published.includes(:provider_identifiers).order('last_published_posts_at DESC').limit(Company::PAGINATION_LIMIT+1).offset(company_params[:offset])
      respond_to do |format|
        format.html {render("index")}
        format.js {render("index.js.erb")}
      end
    end

  end

  def edit
    @mode = 'update'
    @verticals = @company.verticals.map(&:id)
    @submit_button_text = "Save"
    @normalized_pi = @company.provider_identifiers.pluck(:linkedin).join(",")
  end

  def update
    # if params[:commit] == "update_show_in_index"
    #   current_company.update_attribute(:show_in_index, params[:company][:show_in_index]) if current_user.god?
    #   return render :nothing => true
    # end

    @notice = nil
    # params[:company][:linkedin_identifiers] = params[:company][:linkedin_identifiers].gsub(" ", "").split(",")
    @company.assign_attributes company_params
    @verticals = params[:verticals] || []
    @verticals = @verticals.map{|x| x.to_i }
    @normalized_pi = normalize_provider_identifiers(params[:company][:provider_identifier][:linkedin])
    @company.instagram_location_id = get_instagram_location_id(@company.instagram_location_id) if @company.instagram_location_id.length > 12

    if @company.save
      ProviderIdentifier.where(company_id:@company.id).delete_all
      @normalized_pi.split(",").each do |pi|
        ProviderIdentifier.create({company_id:@company.id, linkedin:pi}) 
      end
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
    @is_remote = params[:remote] == "true"
  end

  def choose_layout
    if @is_remote
      'remote'
    elsif ['create'].include?(action_name) && !(current_user && current_user.god_or_admin?)
      'onboarding'
    else
      'application'
    end
  end

  def company_params
    params.permit(:offset, :q, :vertical, :name, :website_url, :users_attributes, :logo, :logo_cache, :short_description, :hq_city, :hq_state, :employee_count, :verticals, :instagram_username, :facebook, :tumblr, :twitter, :jobs_page, :instagram_username_auto_publish, :instagram_location_auto_publish, :facebook_auto_publish, :tumblr_auto_publish, :twitter_auto_publish, :foursquare_auto_publish, :foursquare_v2_id, :instagram_uid, :hex_code, :last_reviewed_posts_at, :last_published_posts_at, :instagram_location_id, :show_in_index, :provider_identifier)
  end
end
