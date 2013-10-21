class LinkedinController < ApplicationController

  layout "onboarding"
  # before_filter :authorize_user, only:[:show]

  def new
  end

  def create
  	if auth = request.env["omniauth.auth"]
  		# raise auth.to_yaml
  		logger.info "+++++++++++++++++++++++"
  		logger.info auth["credentials"].token
  		access_token = auth["credentials"].token
        response = HTTParty.get("https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,positions:(title,is_current,company:(id,name)))", :query=>{oauth2_access_token:access_token, format:"json"})
  		logger.info response.body
  		# redirect_to(user_path(current_user))
  	end
  end

  def destroy
  end
end
