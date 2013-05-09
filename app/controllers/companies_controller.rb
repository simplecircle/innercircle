class CompaniesController < ApplicationController

  # before_filter :restrict_access
  layout :choose_layout

  def new
    @company = Company.new
    @user = @company.users.build
    @profile = @user.build_profile
    @verticals = Vertical.all
  end

  def create
    @company = Company.create(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    @verticals = params[:verticals]
    if @verticals
      @verticals.each do |v|
        CompaniesVertical.create!(company_id: @company.id, vertical_id: v)
      end
    end

    if @company.save
      # session[:company_id] = @company.id
      # session[:user_id] = @company.users.first.id
      @user = @company.users.first
      cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all}
      redirect_to talent_url(subdomain: @company.subdomain)
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
    if ['new', 'create'].include? action_name
      'onboarding'
    else
      'application'
    end
  end
end
