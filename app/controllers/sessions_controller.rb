class SessionsController < ApplicationController

  layout "onboarding"

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      cookies.permanent[:auth_token] = {value: user.auth_token, domain: :all}
      subdomain = user.companies.first.subdomain

      if user.talent?
        redirect_to current_user
      elsif user.god?
        redirect_to companies_url(subdomain:false)
      else
        redirect_to dashboard_url(subdomain: subdomain)
      end

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
