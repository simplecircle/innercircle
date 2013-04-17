class CompaniesController < ApplicationController
  def new
    @company = Company.new
    @user = @company.users.build
  end

  def create
    @company = Company.create(params[:company])
    @company.subdomain = params[:company][:name].to_slug.normalize(:separator=>"").to_s
    if @company.save!
      redirect_to talent_url
    end
  end

  def show
  end

  def edit
  end
end
