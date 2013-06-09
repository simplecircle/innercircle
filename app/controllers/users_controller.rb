class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource
  # auth handled through get_user
  before_filter :authorize_user, only:[:show]
  before_filter :get_user, only:[:edit, :update]

  def new
    @user = User.new :role=>'talent'
    @user.build_profile
    @is_admin_adding = request.fullpath == '/add-talent' && current_user && current_user.god_or_admin?
    @star_rating = 1 if !@is_admin_adding
    @depts = CompanyDept.all
  end

  def create
    @user = @company.users.build(params[:user])
    @user.role = 'talent'
    form_errors = {}
    @is_admin_adding = (params[:is_admin_adding]=="true") && current_user && current_user.god_or_admin?
    @depts = params[:company_depts]
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

    unless @local_join
      # Ensure this password doesn't already exist in future iterations before creation
      @user.password = SecureRandom.urlsafe_base64
    end

    form_errors[:name] = "Please enter first and last name" if @is_admin_adding && (@user.profile.first_name.empty? || @user.profile.last_name.empty?)
    form_errors[:categories] = "You have to choose at least one category." if @depts.nil?
    form_errors[:star_rating] = "Please rate the person you are adding" if @star_rating == 0

    if !form_errors.empty?
      @user.valid?
      form_errors.each do |field, msg|
        @user.errors.add(field, msg)
      end
      render "new"
    else
      if @user.save
        @company.users << @user
        save_departments(@depts, @user.profile)
        save_star_rating(@star_rating, @user.id, @company.id)
        # Scope through auth_token so that an exposed ID for an Edit form won't be in the public domain.
        if @is_admin_adding
          params[:commit] == "Save & add another" ? redirect_to('/add-talent', :notice => "#{@user.profile.full_name} successfully added!") : redirect_to(dashboard_url, :notice => "#{@user.profile.full_name} successfully added!")
        else
          redirect_to(edit_user_url(@user.auth_token))
        end
      else
        render "new"
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
      @incoming_tags = @user.profile.skills.map(&:name).join(',')

      @alert = 'Sorry, LinkedIn authorization failed' if params[:strategy] == 'linkedin' && params[:message] == 'invalid_credentials'

      if auth = request.env["omniauth.auth"]
        info = auth["info"]

        @profile.update_attributes!(
          :linkedin_data => JSON.parse(auth.to_json), 
          :linkedin_profile => info["urls"]["public_profile"]
        )

        @profile.first_name = info["first_name"]
        @profile.last_name = info["last_name"]
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
    end

    if @depts.nil? && validate_depts?
      @user.errors.add(:categories, "You have to choose at least one category.")
      render "edit"
    else
      if @user.save
        save_departments(@depts, @user.profile) if validate_depts?

        if @is_new_user
          redirect_to confirmation_url
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

  def save_star_rating(rating, user_id, company_id)
    UsersCompany.find_by_user_id_and_company_id(user_id, company_id).update_attributes(:star_rating => rating)
  end

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
    @is_new_user = !cookies[:auth_token] || !User.find_by_auth_token(params[:id]).nil? #first case is if they're not logged in, second case is if they are logged in but editing a user based on auth token (which happens if they're at the /join link)

    if @is_new_user
      @auth_token = params[:id] || session[:callback_token] #callback_token will be populated if we're coming back from a linkedin callback
      @user = User.find_by_auth_token(@auth_token)
    else
      @user = current_user
    end
  end

  def find_resource
    @company = request.subdomain.empty? ? current_user.companies.first : current_company
    @local_join= true if params[:local_join] == "true"
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
