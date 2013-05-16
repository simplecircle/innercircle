class ProfilesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:edit, :update]
  before_filter :ensure_proper_subdomain, only: [:show]

  def edit
    if auth = request.env["omniauth.auth"]
      # raise auth.to_yaml
      info = auth["info"]
      @profile.first_name = info["first_name"]
      @profile.last_name = info["last_name"]
      @profile.job_title = info["headline"]
      @profile.url = info["urls"]["public_profile"]
      @profile.linkedin_profile = info["urls"]["public_profile"]
      @incoming_tags = auth["extra"]["raw_info"]["skills"].values[1].map{|s| s.skill.name}.join(",")

      @profile.linkedin_data = JSON.parse(auth.to_json)
      session[:callback_token] = nil
      if session[:linkedin_callback_page] == 'users_edit'
        @depts = @user.profile.company_depts.map(&:id)
        render 'users/edit', :layout => "application"
        session[:linkedin_callback_page] = nil
      else
        @profile.save
      end
    end
  end

  def update
    @incoming_tags = params[:as_values_true]
    @profile.skill_list = @incoming_tags.split(",").reject(&:empty?).join(",")
    if @profile.update_attributes(params[:profile])
        redirect_to confirmation_url
      else
        render "edit"
      end
  end

  def callback_session
    session[:callback_token] = User.find_by_auth_token(params[:id]).auth_token
    session[:linkedin_callback_page] = params[:linkedin_callback_page]
    redirect_to "/auth/linkedin"
  end

  private

  def find_resource
    @user = params[:id]? User.find_by_auth_token(params[:id]) : User.find_by_auth_token(session[:callback_token])
    @profile = @user.profile
    @company = request.subdomain.empty? ? current_user.companies.first : Company.find_by_subdomain!(request.subdomain)
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def ensure_proper_subdomain
    # If you're an admin, force a subdomain. Otherwise, redirect home
    if current_user
      if current_user.role == 'admin' && request.subdomain.empty? && current_user.companies.first != nil
        redirect_to profile_url(subdomain: current_user.companies.first.subdomain)
      elsif current_user.role == 'god' && request.subdomain.empty?
        redirect_to '/'
      end
    end
  end

  def choose_layout
    if ['edit', 'update'].include? action_name
      'onboarding'
    else
      'application'
    end
  end

end
