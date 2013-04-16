class CompaniesController < ApplicationController
  def new
    @company = Company.new
    @user = @company.users.build
  end

  def create
    @company = Company.create(params[:company])
    if @company.save!
      redirect_to root_url
    end
  end

  def show
  end

  def edit
  end
end
