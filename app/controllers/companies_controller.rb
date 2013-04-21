class CompaniesController < ApplicationController

  # before_filter :restrict_access
  layout :choose_layout

  def new
    @company = Company.new
    @user = @company.users.build
  end

  def create
    @company = Company.create(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    if @company.save
      session[:user_id] = @company.users.first.id
      redirect_to talent_url
    else
      render "new"
    end
  end

  def show
  end

  def edit
  end

  private

  def choose_layout
    if ['new'].include? action_name
      'onboarding'
    else
      'application'
    end
  end
end
