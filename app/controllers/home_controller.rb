class HomeController < ApplicationController
  layout "onboarding"

  def index
    if params[:src] != nil #Being directed home from a protected page
      session[:redirect_source] = params[:src]
      redirect_to root_url(subdomain: false)
    elsif current_user && current_user.role == 'admin' && current_user.companies.first != nil && session[:redirect_source] == nil #admin logged in and not being redirected
      redirect_to dashboard_url(subdomain: current_user.companies.first.subdomain)
    else #not an immediate redirect (ie no src query string), so we should clear the redirect source
      session[:redirect_source] = nil
    end
    
  end
end
