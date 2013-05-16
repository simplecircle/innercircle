class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:new, :create, :show]
  before_filter :authorize_user, only:[:show, :update]

  def new
    @user = User.new
    @depts = CompanyDept.all
  end

  def update
    @user = User.find(params[:id])
    @notice = nil
    @depts = params[:company_depts]
    if @depts.nil?
      @user.errors.add(:categories, "You have to choose at least one category.")
      render "edit"
    else
      if current_user.update_attributes(params[:user])
        save_departments(@depts, @user.profile)
        @notice = "Account Updated"
      end
      if current_user.god_or_admin?
        redirect_to dashboard_url, notice: @notice
      else
        redirect_to current_user, notice: @notice
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
      if @user.save
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
      ProfilesCompanyDept.create!(profile_id: profile.id, company_dept_id: dept)
    end
  end

  def find_resource
    @company = request.subdomain.empty? ? current_user.companies.first : Company.find_by_subdomain!(request.subdomain)
    @local_join= true if params[:local_join] == "true"
  end

  def choose_layout
    if ['new', 'create', 'confirmation'].include? action_name
      'onboarding'
    else
      'application'
    end
  end
end
