class ProfilesController < ApplicationController

  layout :choose_layout
  before_filter :find_resource, only: [:show, :update]
  # before_filter :restrict_access_unless_belongs_to_current_user

  def callback
    if auth = request.env["omniauth.auth"]
      logger.info "+++++++++++++++++++++++++++"
      logger.info @skills = auth["extra"]["raw_info"]["skills"].values[1].each{|s| puts s.skill.name}
      # raise auth.to_yaml
    end
  end
  def show
    if auth = request.env["omniauth.auth"]
      raise auth.to_yaml
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
    @profile = Profile.find(params[:id]) || current_user.profile
    # @user is just here for restrict_access_unless_belongs_to_current_user's use.
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
