class DashboardController < ApplicationController

  # ensuring subdomain must be called first!
  before_filter :ensure_proper_subdomain
  before_filter :find_resource
  before_filter :authorize

  def index
    @admins = @company.users.where(role:"admin")
  end

  private

  def find_resource
    @company = current_company
  end

  def ensure_proper_subdomain
    # If you're an admin, force a subdomain. Otherwise, redirect home
    if current_user && request.subdomain.empty?
      if current_user.admin?
        redirect_to dashboard_url(subdomain: current_user.companies.first.subdomain)
      else current_user.god?
        redirect_to '/'
      end
    end
  end

end