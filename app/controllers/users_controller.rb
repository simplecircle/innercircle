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
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def create
    @company = Company.find_by_subdomain!(request.subdomain)
    @user = User.create(params[:user])
    @user.profile.skill_list = params[:skills]
    # Ensure this password doesn't already exist in future iterations before creation
    @user.password = SecureRandom.urlsafe_base64
    @depts = params[:company_depts]
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
    @incoming_tags = params[:as_values_true]
    if @depts.nil?
      @user.errors.add(:categories, "You have to choose at least one category.")
      render "new"
    else
      if @user.save
        @depts.each do |dept|
          ProfilesCompanyDept.create!(profile_id:@user.profile.id, company_dept_id:dept)
        end
        redirect_to confirmation_url
      else
        render "new"
      end
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
