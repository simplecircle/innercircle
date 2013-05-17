class CompaniesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:show]

  def new
    @company = Company.new
    @user = @company.users.build
    @profile = @user.build_profile
    @verticals = Vertical.all
  end

  def create
    @company = Company.new(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    @user = @company.users.first
    @profile = @user.profile

    @verticals = params[:verticals]
    if @verticals
      @verticals.each do |v|
        CompaniesVertical.create!(company_id: @company.id, vertical_id: v)
      end
    end
    if @company.save
      @user = @company.users.first
      cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all}
      redirect_to dashboard_url(subdomain: @company.subdomain)
    else
      render "new"
    end
  end

  def show
    @posts = @company.posts.order("provider_publication_date DESC")
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end

  def choose_layout
    if ['new', 'create'].include? action_name
      'onboarding'
    else
      'application'
    end
  end
end
