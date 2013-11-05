class LinkedinController < ApplicationController

include ActionView::Helpers::TextHelper
  layout "onboarding"

  def new
    session[:company_connections_only] = true if linkedin_params[:company_connections]
  end

  def create
  	user = User.find(current_user)

  	if auth = request.env["omniauth.auth"]
  		# raise auth.to_yaml
      access_token = auth["credentials"].token
  		user.assign_attributes(linkedin_access_token:access_token, linkedin_connections:build_linkedin_connections(access_token))
      if user.save(validate: false)
        company_ids = []
        # Note the IN clause here...
        ProviderIdentifier.where(linkedin:user.linkedin_connections.keys).each{|pi| company_ids << pi.company_id}
        company_ids.uniq!
        company_ids.each{|ci| CompanyConnection.create({user_id:current_user.id, company_id:ci})}
        
        # Ensure companies that were followed in user#create are not attempted to be followed again.
        user.connected_company_ids.reject!{|con_co_id| user.relationships.pluck(:followed_id).include?(con_co_id)}.each do |co_id|
          Relationship.create!(follower_id:user.id, followed_id:co_id)
        end
        
        if session[:company_connections_only] and user.company_connections.blank?
          session.delete(:company_connections_only)
          redirect_to(root_url(), notice:"<h4>YOU MAY NOT HAVE COMPANY CONNECTIONS AT THIS TIME</h4><p>Some of your colleague’s may have their LinkedIn privacy settings locked down. As new companies join or your network changes, connections may form...</p>")
        elsif session[:company_connections_only] and !user.company_connections.blank?
          session.delete(:company_connections_only) 
          redirect_to(root_url(), notice:"<h4>YOU KNOW SOMEONE AT #{pluralize(current_user.company_connections.count, 'company').upcase}!</h4><p>We’ve added these companies to your feed: <b>#{Company.where(id:current_user.company_connections.pluck(:company_id)).pluck(:name).join(", ")}</b>")
        elsif user.company_connections.blank?
    		  redirect_to(root_url(), notice:"<h4>WELCOME TO YOUR NEWS FEED!</h4><p>Looks like you don’t have any LinkedIn connections here just yet. As new companies join or your network changes, connections may form.<br/><br/>In other news, this screen contains the latest content from companies you follow. We started you off by adding a few humdingers. <b>Go ahead, look around...</b></p>")
        else
          redirect_to(root_url(), notice:"<h4>WELCOME TO YOUR NEWS FEED!</h4><p>It contains the latest content from companies you follow. We started you off by adding the <b>#{pluralize(current_user.company_connections.count, 'company')}</b> you have connections at, plus some we recommend. <b>Go ahead, look around...</b></p>")
        end
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

  def linkedin_params
    params.permit!
  end
end
