class LinkedinController < ApplicationController

  layout "onboarding"
  # before_filter :authorize_user, only:[:show]

  def new
  end

  def create
  	if auth = request.env["omniauth.auth"]
  		logger.info auth
  		redirect_to(user_path(current_user))
  	end
  end

  def destroy
  end
end
