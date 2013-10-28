class LinkedinController < ApplicationController

  layout "onboarding"
  # before_filter :authorize_user, only:[:show]

  def new
  end

  def create
  	user = User.find(current_user)
  	if auth = request.env["omniauth.auth"]
  		# raise auth.to_yaml
  		company_connections = {}
  		company_blacklist = ["freelance", "freelancing"]
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
  		# logger.info company_connections
  		user.assign_attributes(linkedin_access_token:access_token, company_connections:company_connections)
        if user.save(validate: false)
  		   redirect_to(root_url())
  	    end
  	end
  end

  def destroy
  end
end