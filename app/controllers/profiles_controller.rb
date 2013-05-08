class ProfilesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:show, :update]
  before_filter :restrict_access_unless_belongs_to_current_user

  def show
    if auth = request.env["omniauth.auth"]
      info = auth["info"]
      @profile.first_name = info["first_name"]
      @profile.last_name = info["last_name"]
      @profile.job_title = info["headline"]
      @profile.url = info["urls"]["public_profile"]
      @incoming_tags = auth["extra"]["raw_info"]["skills"].values[1].map{|s| s.skill.name}.join(",")
      # raise auth.to_yaml
    end
  end

  def update
    @incoming_tags = params[:as_values_true]
    @profile.skill_list = @incoming_tags.split(",").reject(&:empty?).join(",")
    if @profile.update_attributes(params[:profile])
        redirect_to confirmation_url
      else
        render "show"
      end
  end

  private

  def find_resource
    # Use current_user for linkedin callback
    @profile = params[:id]? Profile.find(params[:id]) : current_user.profile
    @user = @profile.user
    @company = Company.find_by_subdomain!(request.subdomain)
    @tags = ActsAsTaggableOn::Tag.all.to_json(only: :name)
  end

  def choose_layout
    if ['show', 'update'].include? action_name
      'onboarding'
    else
      'application'
    end
  end

end
