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

  def capitalize_phrase(phrase)
    phrase.split.each{|x|x.capitalize!}.join(" ")
  end

  def first_name(full_name)
    full_name.split.first.capitalize
  end
end
