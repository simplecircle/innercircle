class DashboardController < ApplicationController

  # ensuring subdomain must be called first!
  before_filter :ensure_proper_subdomain
  before_filter :find_resource
  before_filter :authorize

  def index
    @creative = User.by_category(@company.subdomain, "creative")
    @operations = User.by_category(@company.subdomain, "operations")
    @sales_marketing = User.by_category(@company.subdomain, "sales & marketing")
    @technology = User.by_category(@company.subdomain, "technology")
    @admins = @company.users.where(role:"admin")
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end

  def ensure_proper_subdomain
    # If you're an admin, force a subdomain. Otherwise, redirect home
    if current_user
      if current_user.role == 'admin' && request.subdomain.empty? && current_user.companies.first != nil
        redirect_to dashboard_url(subdomain: current_user.companies.first.subdomain)
      elsif current_user.role == 'god' && request.subdomain.empty?
        redirect_to '/'
      end
    end
  end

end