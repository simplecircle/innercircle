class LinkedinController < ApplicationController

  layout "onboarding"
  # before_filter :authorize_user, only:[:show]

  def new
  end

  def create
  	user = User.find(current_user)
  	if auth = request.env["omniauth.auth"]
  		# raise auth.to_yaml
      access_token = auth["credentials"].token
  		user.assign_attributes(linkedin_access_token:access_token, linkedin_connections:build_linkedin_connections(access_token))
      if user.save(validate: false)
        company_ids = []
        # note the IN clause here...
        ProviderIdentifier.where(linkedin:user.linkedin_connections.keys).each{|pi| company_ids << pi.company_id}
        company_ids.uniq!
        company_ids.each{|ci| CompanyConnection.create({user_id:current_user.id, company_id:ci})}

        # (featured companies) buzzfeed, meetup, warby parker, general assembly, squarespace, songza, huge inc, newscred, kickstarter, razorfush ny
        user.connected_companies.pluck(:id).concat([73, 72, 64, 49, 48, 43, 40, 39, 18, 47]).uniq.each do |co_id|
          Relationship.create!(follower_id:user.id, followed_id:co_id)
        end
  		  redirect_to(root_url(), notice:"<h3>OK, YOU’RE READY TO GO!</h3><p>This is your news feed. Recent content from companies you follow shows up here. To get the ball rolling, we followed the <b>#{current_user.company_connections.count}</b> companies you have <span class='connection_flag'>in</span> connections at, plus some we recommend. <b>Go ahead and explore...</b></p>")
  	  end
  	end
  end

  def destroy
  end

  private

  # Page through all connections as needed and build out the custom structure.
  def build_linkedin_connections(access_token, offset=0)
    offset = offset
    @company_connections ||= {}
    company_blacklist = ["freelance", "freelancing", "selfemployed", "independent"]

    response = HTTParty.get("https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,public-profile-url,picture-url,positions:(title,is_current,company:(id,name)))", :query=>{oauth2_access_token:access_token, format:"json", start:offset})
    response = JSON.parse(response.body)
    # logger.info response["values"].size

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
            (@company_connections[position['company']['id'].to_s.downcase] ||= []) << built_connection
          else 
            unless company_blacklist.include?(position['company']['name'].to_s.downcase.gsub(" ",""))
            (@company_connections[position['company']['name'].to_s.downcase.gsub(" ","")] ||= []) << built_connection
            end
            end
          end
        end
      end
    end
    
    offset += 500 # 500 is the default LinkedIn result count.
    if response["_total"] >= offset
      build_linkedin_connections(access_token, offset)
    end
    @company_connections
  end
end
