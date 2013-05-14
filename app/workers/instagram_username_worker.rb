class InstagramUsernameWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty


  def perform(company_id)
    company = Company.find(company_id)
    if company.instagram_uid.nil?
      uid = self.get_uid(company.instagram_username)
      company.update_attribute!(:instagram_uid, uid)
    end

    media = self.get_media(company.instagram_uid)
    media["data"].each do |post|
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid("instagram", post["id"])
        Post.create({
          provider:"instagram",
          provider_uid:post["id"],
          provider_publication_date:Time.at(post["created_time"].to_i).to_datetime,
          provider_raw_data:JSON.parse(post.to_json),
          media_url:post["images"]["standard_resolution"]["url"],
          like_count:post["likes"]["count"],
          published:company.instagram_username_auto_publish
         })
      end
    end
  end

  def get_media(uid)
    # develop a sustainable access_token strategy!!!
    HTTParty.get("https://api.instagram.com/v1/users/#{uid}/media/recent",
      :query=>{:access_token=>"20779015.1fb234f.30609b83744b49118a56939d1e492ffe"})
  end

  def get_uid(username)
    HTTParty.get("https://api.instagram.com/v1/users/search?q=#{username}",
        :query=>{:client_id=>CLIENT_ID})["data"].first["id"]
  end

  # def self.get_user code
  #   response = post("https://api.instagram.com/oauth/access_token",
  #         :body=>{
  #           :client_id=>CLIENT_ID,
  #           :client_secret=>CLIENT_SECRET,
  #           :grant_type=>"authorization_code",
  #           :redirect_uri=>OAUTH_CALLBACK,
  #           :code=>code}).parsed_response
  #   if response["error_type"]
  #     raise response["error_type"]
  #   else
  #     response
  #   end
  # end
end