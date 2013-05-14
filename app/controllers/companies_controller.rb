class CompaniesController < ApplicationController

  layout :choose_layout

  def new
    @company = Company.new
    @user = @company.users.build
    @profile = @user.build_profile
    @verticals = Vertical.all
  end

  def update
    @company = current_user.owned_companies.find(params[:id])
    if @company
      @company.update_attributes! params[:company]
      save_verticals(params[:verticals], @company)
    end
    redirect_to dashboard_url, notice:"Profile Updated"
  end

  def create
    @company = Company.new(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    @user = @company.users.first
    @profile = @user.profile

    @verticals = params[:verticals].map{|v| v.to_i}
    if @company.save
      @user = @company.users.first
      save_verticals(@verticals, @company) if @verticals
      cookies.permanent[:auth_token] = {value: @user.auth_token, domain: :all}
      redirect_to dashboard_url(subdomain: @company.subdomain)
    else
      render "new"
    end
  end

  def save_verticals(verticals, company)
    #Destroy vertical association if the user unchecked it in form
    company.verticals.each do |v|
      if !verticals.include? v.id.to_s
        CompaniesVertical.where(:company_id => company.id, :vertical_id=> v.id).destroy_all
      end
    end
    verticals.each do |v|
      logger.info v
      CompaniesVertical.create!(company_id: company.id, vertical_id: v)
    end
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
