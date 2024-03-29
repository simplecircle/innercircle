class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource
  # auth handled through get_user
  before_filter :authorize_user, only:[:show]
  before_filter :get_user, only:[:edit, :update]

  def new
    #User is already a member
    if current_user && current_user.talent?
      return redirect_to @company if current_user.member_of?(@company.id)

      #Add user to company's talent community
      UsersCompany.create(user_id: current_user.id, company_id: @company.id)
      UserMailer.welcome(current_user, capitalize_phrase(@company.name)).deliver

      if !current_user.has_filled_out_profile
        redirect_to edit_user_url(current_user.auth_token), notice: "You've joined #{@company.name}'s talent community!"
      else
        redirect_to confirmation_url
      end
    elsif current_user && current_user.admin? && @company != current_user.companies.first
      redirect_to :back, alert: "You're currently logged in as an admin. Please log out to join another company's talent community"
    else
      # Check for email stored in session
      if User.find_by_email(session[:email])
        @user = User.find_by_email(session[:email])
        @depts = @user.profile.company_depts.map(&:id)
        @other_job_category = @user.profile.profiles_company_depts.empty? ? nil : @user.profile.profiles_company_depts.first.other_job_category
      else
        @user = User.new :role=>'talent'
        @user.build_profile
        @is_admin_adding = request.fullpath == '/add-talent' && current_user && current_user.god_or_admin?
        @star_rating = 1 if !@is_admin_adding
        @depts = CompanyDept.all
      end
    end
  end

  def create
    existing_user = User.find_by_email(params[:user][:email])
    if existing_user
      if request.xhr?
        respond_to do |format|
          format.json { render :json => {:email => ["You're already signed up with us, thanks!"]} }
        end
        return
      else
        @company.users << existing_user
        return redirect_to confirmation_url
      end
    end
    @user = @company.users.build(params[:user])
    @user.role = 'talent'
    form_errors = {}
    @is_admin_adding = (params[:is_admin_adding]=="true") && current_user && current_user.god_or_admin?
    @depts = params[:company_depts]
    @other_job_category = params[:other_job_category].first
    @star_rating = @is_admin_adding ? params[:star_rating].to_i : 1 #Default to one star for new user signing up

    if @is_admin_adding
      @profile = @user.profile

      #Save skill list
      if !params[:as_values_true].blank?
        @incoming_tags = params[:as_values_true].split(",").reject(&:empty?).join(",")
        @user.profile.skill_list = @incoming_tags #Need to define it this way so that tags populate on form reload (i.e. if validation fails)
      end
    else
      @user.build_profile
    end

    @user.password = SecureRandom.urlsafe_base64

    form_errors[:name] = "Please enter first and last name" if @is_admin_adding && (@user.profile.first_name.empty? || @user.profile.last_name.empty?)
    form_errors[:categories] = "You have to choose at least one category." if @depts.nil?
    form_errors[:other_job_category] = "Please tell us which category fits you best" if !@depts.nil? && CompanyDept.find(@depts.first.to_i).name == "other" && @other_job_category.blank?
    form_errors[:star_rating] = "Please rate the person you are adding" if @star_rating == 0

    if !form_errors.empty?
      @user.valid?
      form_errors.each do |field, msg|
        @user.errors.add(field, msg)
      end
      if request.xhr?
        respond_to do |format|
          format.json { render :json => @user.errors.to_json }
        end
      else
        render "new"
      end
    else
      if @user.save
        @company.users << @user
        save_departments(@depts, @user.profile, @other_job_category)
        save_star_rating(@star_rating, @user.id, @company.id)
        save_referral_source(@user, params[:referral_source] || "__utmz=#{cookies[:__utmz]}")
        # Scope through auth_token so that an exposed ID for an Edit form won't be in the public domain.
        if @is_admin_adding
          params[:commit] == "Save & add another" ? redirect_to('/add-talent', :notice => "#{@user.profile.full_name} successfully added!") : redirect_to(dashboard_url, :notice => "#{@user.profile.full_name} successfully added!")
        else
          #log in user if there's no current user
          log_in_new_user(@user)
          @user.set_password_reset_token
          if request.xhr?
            respond_to do |format|
              format.json { render :json => {:success=>edit_user_url(@user.auth_token, is_kiosk:params[:is_kiosk]) }}
            end
          else
            redirect_to(edit_user_url(@user.auth_token))
          end
        end
        UserMailer.welcome(@user, capitalize_phrase(@company.name)).deliver
      else
        if request.xhr?
          respond_to do |format|
            format.json { render :json => @user.errors.to_json }
          end
        else
          render "new"
        end
      end
    end
  end

  def show
    @user = User.find(params[:id])
    @star_rating = @user.star_rating(@company.id) if current_user.god_or_admin?
  end

  def edit
    if params[:autofill] == 'linkedin' #The link for the 'autofill with linkedin' button looks like users/token/edit?autofill=linkedin, so this catches that url and redirects to the linkedin auth page
      session[:callback_token] = @user.auth_token
      redirect_to "/auth/linkedin"
    else
      @profile = @user.profile
      @depts = @profile.company_depts.map(&:id)
      @other_job_category = @profile.profiles_company_depts.empty? ? nil : @profile.profiles_company_depts.first.other_job_category
      @incoming_tags = @user.profile.skills.map(&:name).join(',')

      @alert = 'Sorry, LinkedIn authorization failed' if params[:strategy] == 'linkedin' && params[:message] == 'invalid_credentials'
      
      auth = request.env["omniauth.auth"]
      if auth
        info = auth["info"]

        @profile.update_attributes!(
          :linkedin_data => JSON.parse(auth.to_json), 
          :linkedin_profile => info["urls"]["public_profile"]
        )

        @profile.first_name = info["first_name"]
        @profile.last_name = info["last_name"]
        @profile.job_title = info["headline"]
        @profile.url = info["urls"]["public_profile"]
        @incoming_tags = @incoming_tags + ',' + auth["extra"]["raw_info"]["skills"].values[1].map{|s| s.skill.name}.join(",") unless auth["extra"]["raw_info"]["skills"].nil?

        session[:callback_token] = nil
        if @is_new_user
          @profile.save
        end
      end
    end
  end

  def update
    if params[:commit] == "Remove User"
      user_to_delete = User.find(params[:id])
      UsersCompany.where(:company_id => @company.id, :user_id => user_to_delete.id).destroy_all
      return redirect_to dashboard_url, notice: "#{user_to_delete.email} removed from your talent community"
    end
    if params[:commit] == "Save Rating"
      user = User.find(params[:id])
      star_rating = params[:user][:star_rating].to_i
      save_star_rating(star_rating, user.id, @company.id)
      return render :nothing => true
    end
    @user.assign_attributes(params[:user])

    def validate_depts?
      #only validate depts if an existing user, otherwise it will try to validate page 2 of the signup wizard, which doesn't have any depts on it
      !@is_new_user && @user.talent?
    end

    #Save skill list
    if !params[:as_values_true].blank?
      @incoming_tags = params[:as_values_true].split(",").reject(&:empty?).join(",")
      @user.profile.skill_list = @incoming_tags #Need to define it this way so that tags populate on form reload (i.e. if validation fails)
    end

    if validate_depts?
      @depts = params[:company_depts]
      @depts = @depts.map{|x| x.to_i } if !@depts.blank?
      @other_job_category = params[:other_job_category].first
    end

    if validate_depts? && @depts.nil?
      @user.errors.add(:categories, "You have to choose at least one category.")
      throw_err = true
    end

    #Check if user selected "other" but didn't specify
    if validate_depts? && !@depts.nil? && CompanyDept.find(@depts.first.to_i).name == "other" && @other_job_category.blank?
      @user.errors.add(:other_job_category, "Please tell us which category fits you best") if 
      throw_err == true
    end

    if throw_err  
      render "edit"
    else
      if @user.save
        save_departments(@depts, @user.profile, @other_job_category) if validate_depts?
        
        # Add / update mailchimp lists
        if @user.talent? && Rails.env == "production"
          mc = Mailchimp.new
          mc.list_subscribe(@user)
        end

        if @is_new_user
          log_in_new_user @user
          @company.users << @user
          redirect_to confirmation_url(is_kiosk: params[:is_kiosk])
        elsif current_user.god_or_admin?
          redirect_to dashboard_url, notice: "Account Updated"
        else
          redirect_to current_user, notice: "Account Updated"
        end
      else
        render 'edit'
      end
    end
  end

  def confirmation
    @is_admin_adding = current_user && current_user.god_or_admin?
  end

  private

  def log_in_new_user(user)
    cookies.permanent[:auth_token] = {value: user.auth_token, domain: :all} unless current_user || params[:is_kiosk] == "true"
  end

  def save_star_rating(rating, user_id, company_id)
    UsersCompany.find_by_user_id_and_company_id(user_id, company_id).update_attributes(:star_rating => rating)
  end

  def save_referral_source(user, cookie_string)
    if cookie_string.length > 0
      ga = GoogleAnalyticsParser.new
      user.update_attribute(:referral_source, ga.parse(cookie_string))
    end
  end

  def save_departments(departments, profile, other_job_category)
    #Destroy category association if the user unchecked it in form
    profile.company_depts.each do |dept|
      if !departments.include? dept.id.to_s
        ProfilesCompanyDept.where(:profile_id => profile.id, :company_dept_id=> dept.id).destroy_all
      end
    end
    departments.each do |dept|
      pcd = ProfilesCompanyDept.find_or_create_by_profile_id_and_company_dept_id(profile.id, dept)
      pcd.update_attribute(:other_job_category, other_job_category) if pcd.company_dept.name == "other"
    end
  end

  def get_user
    @is_new_user = !cookies[:auth_token] || !User.find_by_auth_token(params[:id]).nil? #first case is if they're not logged in, second case is if they are logged in but editing a user based on auth token (which happens if they're at the /join link)

    if @is_new_user
      @auth_token = params[:id] || session[:callback_token] #callback_token will be populated if we're coming back from a linkedin callback
      @user = User.find_by_auth_token(@auth_token)
    else
      @user = current_user
    end

    @user = User.find_by_email(session[:email]) if !@user #try to get user by email address stored in session, in the case that they're coming from a newsletter link
      
  end

  def find_resource
    @newsletter_subscription = request.env["HTTP_REFERER"] && !request.env["HTTP_REFERER"].match(/newsletter/i).nil? || params[:is_kiosk] == "true"
    if @newsletter_subscription
      @company = Company.find_by_subdomain('talent')
    else
      @company = request.subdomain.empty? ? current_user.companies.first : current_company
    end
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if !cookies[:auth_token] || action_name == "confirmation" #always onboarding if not logged in or are on the confirmation page
      'onboarding'
    elsif ['update', 'edit'].include?(action_name) && @is_new_user
      'onboarding'
    elsif ['new', 'create'].include?(action_name) && !@is_admin_adding
      'onboarding'
    else
      'application'
    end
  end
end
