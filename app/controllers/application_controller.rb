class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user, :capitalize_phrase, :current_company, :referrer

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def current_company
    @current_company ||= Company.find_by_subdomain(request.subdomain)
  end

  def authorize
    if current_user
      #God users included in has_privileges_to logic
      return if current_user.has_privileges_to(current_company.id)
    end
    redirect_to(login_url)
  end

  def authorize_user
    return if User.find(params[:id]) == current_user

    # Check if user is admin/god and they have access to the user
    return if current_user.has_privileges_to(current_company.id) && current_company.users.map(&:id).include?(params[:id].to_i)

    redirect_to(login_url)
  end

  def belongs_to_current_user?
    if current_user
      current_user.id == @user.id
    else
      false
    end
  end

  def referrer
    referrer = request.env["HTTP_REFERER"]
    (referrer.nil? || referrer.match(/(jobcrush\.)|(innercircle\.)|(\.circ\.)/i).nil?) ? "external" : "internal"
  end

  def sort_by_star_rating(array, company_id)
    array.sort {|a, b| b.star_rating(company_id) <=> a.star_rating(company_id)}
  end

  def capitalize_phrase(phrase)
    phrase.split.each{|x|x.capitalize!}.join(" ")
  end
end
