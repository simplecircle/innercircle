class UsersController < ApplicationController

  layout :choose_layout
  before_filter :restrict_access, only:[:index, :show]
  before_filter :find_resource, only: [:new, :create]


  def index
  end

  def new
    @user = User.new
    @profile = @user.build_profile
    @depts = CompanyDept.all
  end

  def create
    @user = User.create(params[:user])
    # Ensure this password doesn't already exist in future iterations before creation
    @user.password = SecureRandom.urlsafe_base64
    @incoming_tags = params[:as_values_true]
    @user.profile.skill_list = @incoming_tags.split(",").reject(&:empty?).join(",")
    @depts = params[:company_depts]
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

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if ['new', 'confirmation'].include? action_name
      'public'
    else
      'application'
    end
  end
end
