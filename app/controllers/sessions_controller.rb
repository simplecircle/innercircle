class SessionsController < ApplicationController

  layout "onboarding"

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      cookies.permanent[:auth_token] = {value: user.auth_token, domain: :all}
      redirect_to dashboard_url(subdomain: user.companies.first.subdomain)
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token, domain: :all)
    redirect_to root_url(subdomain: false, src:"logout"), notice: "Logged out."
  end
end
