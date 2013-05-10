class DashboardController < ApplicationController
  layout "application"
  before_filter :restrict_access, only:[:index]
  before_filter :ensure_proper_subdomain
  before_filter :find_resource

  def index
    @creative = User.by_category(@company.subdomain, "Creative")
    @operations = User.by_category(@company.subdomain, "Operations")
    @sales_marketing = User.by_category(@company.subdomain, "Sales & Marketing")
    @technology = User.by_category(@company.subdomain, "Technology")
    @admins = @company.users.where :role => "admin"
    @headline = ""
  end

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end
  def ensure_proper_subdomain
    # If you're an admin, force a subdomain. Otherwise, if you're a god (like Kanye West), redirect home (or the "companies list", when we create that)
    if current_user.role == 'admin' && request.subdomain.empty? && current_user.companies.first != nil
      redirect_to dashboard_url(:host => current_user.companies.first.subdomain + '.' + request.domain)
    elsif current_user.role == 'god' && request.subdomain.empty?
      redirect_to '/'
    end      
  end
end