class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :capitalize_phrase, :first_name

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def restrict_access
    redirect_to(login_url) unless current_user
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
