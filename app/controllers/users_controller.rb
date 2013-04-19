class UsersController < ApplicationController

  layout :choose_layout
  before_filter :restrict_access, only:[:index, :show]

  def index
  end

  def new
    @company = Company.find_by_subdomain!(request.subdomain)
    @user = User.new
    @profile = @user.build_profile
    @depts = CompanyDept.all
  end

  def create
    @user = User.create(params[:user])
    @user.skip_password_validation = true
    if @user.save!
      params[:company_depts].each do |key, value|
        if value.to_i == 1
          ProfilesCompanyDept.create!(profile_id:@user.profile.id, company_dept_id:key)
        end
      end
      redirect_to confirmation_url
    end
  end

  def show
  end

  def confirmation
  end

  private

  def choose_layout
    if ['new', 'confirmation'].include? action_name
      'public'
    else
      'application'
    end
  end
end
