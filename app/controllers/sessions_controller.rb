class SessionsController < ApplicationController

  layout "onboarding"

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      cookies.permanent[:auth_token] = {value:user.auth_token, domain: :all}
      # this session will not be needed once all company finds are scoped through the subdomain
      # session[:company_id] = user.companies.first.id
      subdomain = user.companies.first.subdomain
      subdomain += "." unless subdomain.empty?
      redirect_to talent_url(:host => subdomain + request.domain)
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token, domain: :all)
    # this session will not be needed once all company finds are scoped through the subdomain
    # session[:company_id] = nil
    redirect_to root_url(subdomain: false), notice: "Logged out."
  end
end
