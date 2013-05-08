class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_company, :capitalize_phrase, :first_name

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_company
    @current_company ||= Company.find(session[:company_id]) if session[:company_id]
  end

  def restrict_access
    redirect_to(login_url) unless current_user
  end

  def restrict_access_unless_belongs_to_current_user
    if current_user
      unless current_user.id == @user.id
        redirect_to(login_url)
      end
    else
      redirect_to(login_url)
    end
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
