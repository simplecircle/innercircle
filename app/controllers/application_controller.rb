class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user, :capitalize_phrase

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def authorize
    if current_user
      return if current_user.god?
      Company.find_by_subdomain!(request.subdomain).users.select("users.id").where(role:"admin").each {|user| return if user.id == current_user.id} #Get list of all admins for the company being accessed (through the subdomain) and make sure the current user is an admin for that company
    end
    redirect_to(login_url)
  end

  def authorize_user
    return if User.find(params[:id]) == current_user #Check to see that they match up with the id being requested
    authorize #defer to authorize, which checks for admin and god
  end

  def belongs_to_current_user?
    if current_user
      current_user.id == @user.id
    else
      false
    end
  end

  def capitalize_phrase(phrase)
    phrase.split.each{|x|x.capitalize!}.join(" ")
  end
end
