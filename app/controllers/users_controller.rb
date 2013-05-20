class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource
  before_filter :authorize_user, only:[:show]
  before_filter :get_user, only:[:edit, :update]

  def new
    @user = User.new
    @depts = CompanyDept.all
  end

  def update
    id = params[:id]
    if User.where(id:id).first != current_user && User.find_by_auth_token(id).blank?
      redirect_to(login_url, alert:"<h3>Please log in</h3>")
    else
      @user.assign_attributes(params[:user])
      @notice = nil
      validate_depts = !@new_user && @user.talent? #only validate depts if an existing user, otherwise it will try to validate page 2 of the signup wizard, which doesn't have any depts on it

      #Save skill list
      if !params[:as_values_true].blank?
        @incoming_tags = params[:as_values_true].split(",").reject(&:empty?).join(",")
        @user.profile.skill_list = @incoming_tags #Need to define it this way so that tags populate on form reload (i.e. if validation fails)
      end

      if validate_depts
        @depts = params[:company_depts]
        @depts = @depts.map{|x| x.to_i } if !@depts.blank?
      end

      if @depts.nil? && validate_depts
        @user.errors.add(:categories, "You have to choose at least one category.")
        render "edit"
      else
        if @user.save
          save_departments(@depts, @user.profile) if validate_depts
          @notice = "Account Updated"

          if @new_user
            redirect_to confirmation_url
          elsif current_user.god_or_admin?
            redirect_to dashboard_url, notice: @notice
          else 
            redirect_to current_user, notice: @notice
          end
        else
          render 'edit'
        end
      end
    end
  end

  def create
    @user = @company.users.build(params[:user])
    @user.role = 'talent'
    @user.build_profile
    @depts = params[:company_depts]
    unless @local_join
      # Ensure this password doesn't already exist in future iterations before creation
      @user.password = SecureRandom.urlsafe_base64
    end
    if @depts.nil?
      @user.valid?
      @user.errors.add(:categories, "You have to choose at least one category.")
      render "new"
    else
      if @user.save
        @company.users << @user
        save_departments(@depts, @user.profile)
        # Scope through auth_token so that an exposed ID for an Edit form won't be in the public domain.
        redirect_to edit_user_url(@user.auth_token)
      else
        render "new"
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    if params[:autofill] == 'linkedin' #The link for the 'autofill with linkedin' button looks like users/token/edit?autofill=linkedin, so this catches that url and redirects to the linkedin auth page
      session[:callback_token] = @user.auth_token
      redirect_to "/auth/linkedin"
    else

      @profile = @user.profile
      @depts = @profile.company_depts.map(&:id)
      @incoming_tags = @user.profile.skills.map(&:name).join(',')

      if auth = request.env["omniauth.auth"]
        info = auth["info"]

        @profile.update_attributes!(
          :linkedin_data => JSON.parse(auth.to_json), 
          :linkedin_profile => info["urls"]["public_profile"]
        )

        @profile.first_name = info["first_name"]
        @profile.last_name = info["last_name"]
        @profile.job_title = info["headline"]
        @profile.url = info["urls"]["public_profile"]
        @incoming_tags = @incoming_tags + ',' + auth["extra"]["raw_info"]["skills"].values[1].map{|s| s.skill.name}.join(",")

        session[:callback_token] = nil
        if @new_user
          @profile.save
        end
      end
    end
  end

  def confirmation
  end

  private

  def save_departments(departments, profile)
    #Destroy category association if the user unchecked it in form
    profile.company_depts.each do |dept|
      if !departments.include? dept.id.to_s
        ProfilesCompanyDept.where(:profile_id => profile.id, :company_dept_id=> dept.id).destroy_all
      end
    end
    departments.each do |dept|
      ProfilesCompanyDept.find_or_create_by_profile_id_and_company_dept_id(profile.id, dept)
    end
  end

  def get_user
    @new_user = !User.find_by_auth_token(params[:id]).blank? || !cookies[:auth_token]

    if @new_user
      @auth_token = params[:id] || session[:callback_token] #callback_token will be populated if we're coming back from a linkedin callback
      @user = User.find_by_auth_token(@auth_token) || User.find(params[:id])
    else
      @user = current_user
    end
  end

  def find_resource
    @company = request.subdomain.empty? ? current_user.companies.first : Company.find_by_subdomain!(request.subdomain)
    @local_join= true if params[:local_join] == "true"
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if ['new', 'create', 'confirmation'].include?(action_name) || !cookies[:auth_token]
      'onboarding'
    else
      'application'
    end
  end
end
