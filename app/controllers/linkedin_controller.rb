class LinkedinController < ApplicationController

  layout "onboarding"
  # before_filter :authorize_user, only:[:show]

  def new
  end

  def create
  	if auth = request.env["omniauth.auth"]
  		# raise auth.to_yaml
  		company_connections = {}
  		company_blacklist = ["freelance"]
  		access_token = auth["credentials"].token
        response = HTTParty.get("https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,public-profile-url,picture-url,positions:(title,is_current,company:(id,name)))", :query=>{oauth2_access_token:access_token, format:"json"})
  		response = JSON.parse(response.body)
  		 # logger.info response

  		response['values'].each do |connection|
  	 	  built_connection = {}
  	 	  built_connection['id'] = connection['id']
  	 	  built_connection['first_name'] = connection['firstName']
  	 	  built_connection['last_name'] = connection['lastName']
  	 	  built_connection['public_profile_url'] = connection['publicProfileUrl']
  	 	  built_connection['picture_url'] = connection['pictureUrl']

  		  if connection['positions']
  		  	if connection['positions']['values']
  		  	  connection['positions']['values'].each do |position|
  		  	 	if position['company']['id']
  		  	 	  (company_connections[position['company']['id'].to_s.downcase] ||= []) << built_connection
  		  	 	else 
  		  	 	  unless company_blacklist.include?(position['company']['name'].to_s.downcase)
    		  	 	(company_connections[position['company']['name'].to_s.downcase] ||= []) << built_connection
    		  	  end
  		  	    end
  		  	  end
  		    end
  		  end
  		end
  		logger.info company_connections
  		# redirect_to(user_path(current_user))
  	end
  end

  def destroy
  end
end
