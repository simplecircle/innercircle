class UsersController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:new, :create, :show]
  before_filter :authorize, only:[:show]


  def new
    @user = User.new
    @depts = CompanyDept.all
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
        @depts.each do |dept|
          ProfilesCompanyDept.create!(profile_id:@user.profile.id, company_dept_id:dept)
        end
        # Scope through auth_token so that an exposed ID for an Edit form won't be in the public domain.
        redirect_to edit_profile_url(@user.auth_token)
      else
        render "new"
      end
    end
  end

  def show
    @user = @company.users.find(params[:id])
  end

  def confirmation
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
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
