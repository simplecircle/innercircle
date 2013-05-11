class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user, :capitalize_phrase

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def restrict_access
    if current_user
      return if current_user.role == "god"
      Company.find_by_subdomain!(request.subdomain).users.select("users.id").where(role:"admin").each {|user| return if user.id == current_user.id}
    end
    redirect_to(login_url)
  end

  def belongs_to_current_user?
    if current_user
      if current_user.id == @user.id
        true
      else
        false
      end
    else
      false
    end
  end

  def capitalize_phrase(phrase)
    phrase.split.each{|x|x.capitalize!}.join(" ")
  end
end
