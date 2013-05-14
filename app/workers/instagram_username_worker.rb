class InstagramUsernameWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty

  def perform(company_id, first_run=false)
    @first_run = first_run
    import(company_id)
  end

  def get_media(uid, next_max_id=nil)
    # develop a sustainable access_token strategy!!!
    HTTParty.get("https://api.instagram.com/v1/users/#{uid}/media/recent",
      :query=>{access_token:"20779015.1fb234f.30609b83744b49118a56939d1e492ffe", max_id:next_max_id})
  end

  def get_uid(username)
    HTTParty.get("https://api.instagram.com/v1/users/search?q=#{username}",
        :query=>{client_id:CLIENT_ID})["data"].first["id"]
  end

  def import(company_id, next_max_id=nil)
    company = Company.find(company_id)
    if company.instagram_uid.nil?
      uid = self.get_uid(company.instagram_username)
      company.update_attribute!(:instagram_uid, uid)
    end

    media = self.get_media(company.instagram_uid, next_max_id)
    # logger.info media.to_yaml
    # logger.info "next_max_id -- #{next_max_id}"
    # logger.info "pagination -- #{media["pagination"]}"
    media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]
    # logger.info "next_max_id  -- #{next_max_id}"
    media["data"].each do |post|
      logger.info "check if post exists"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid("instagram", post["id"])
        post = Post.create({
          provider:"instagram",
          provider_uid:post["id"],
          provider_publication_date:Time.at(post["created_time"].to_i).to_datetime,
          provider_raw_data:JSON.parse(post.to_json),
          media_url:post["images"]["standard_resolution"]["url"],
          like_count:post["likes"]["count"],
          published:company.instagram_username_auto_publish
         })
        logger.info "Post #{post.id} created"
      end
    end
    if @first_run == "true"
      unless next_max_id.nil?
        import(company_id, next_max_id)
      end
    end
  end

end