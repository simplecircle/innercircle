class ProfilesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:edit, :update]

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
      @profile.save
      session[:callback_token] = nil
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
    redirect_to "/auth/linkedin"
  end


  private

  def find_resource
    @user = params[:id]? User.find_by_auth_token(params[:id]) : User.find_by_auth_token(session[:callback_token])
    @profile = @user.profile
    @company = Company.find_by_subdomain!(request.subdomain)
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if ['edit', 'update'].include? action_name
      'onboarding'
    else
      'application'
    end
  end

end
