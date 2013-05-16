class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource
  before_filter :authorize_user, only:[:show, :update]

  def new
    @user = User.new
    @depts = CompanyDept.all
  end

  def update
    @user = User.find(params[:id])
    @user.assign_attributes(params[:user])
    @notice = nil
    @depts = params[:company_depts]
    @depts = @depts.map{|x| x.to_i } if !@depts.blank?

    if !params[:as_values_true].blank?
      @incoming_tags = params[:as_values_true].split(",").reject(&:empty?).join(",")
      @user.profile.skill_list = @incoming_tags #Need to define it this way so that tags populate on form reload (i.e. if validation fails)
    end

    if @depts.nil? && @user.talent?
      @user.errors.add(:categories, "You have to choose at least one category.")
      render "edit"
    else
      if @user.save
        save_departments(@depts, @user.profile) if @user.talent?
        @notice = "Account Updated"
        if current_user.god_or_admin?
          redirect_to dashboard_url, notice: @notice
        else
          redirect_to current_user, notice: @notice
        end
      else
        render 'edit'
      end
    end
  end

  def create
    @user = @company.users.build(params[:user])
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
      if @user.save!
        @company.users << @user
        save_departments(@depts, @user.profile)
        # Scope through auth_token so that an exposed ID for an Edit form won't be in the public domain.
        redirect_to edit_profile_url(@user.auth_token)
      else
        render "new"
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
    @depts = @user.profile.company_depts.map(&:id)
    @incoming_tags = @user.profile.skills.map(&:name).join(',')
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

  def find_resource
    @company = request.subdomain.empty? ? current_user.companies.first : Company.find_by_subdomain!(request.subdomain)
    @local_join= true if params[:local_join] == "true"
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if ['new', 'create', 'confirmation'].include? action_name
      'onboarding'
    else
      'application'
    end
  end
end
