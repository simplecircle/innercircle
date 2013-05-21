class InstagramUsernameWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty
  PROVIDER = "instagram"

  def perform(company_id, first_run=false)
    if first_run
      @first_run = first_run
      @count = 200
    else
      @count = 10
    end
    import(Company.find(company_id))
  end

  def get_media(uid, next_max_id=nil)
    # develop a sustainable access_token strategy!!!
    HTTParty.get("https://api.instagram.com/v1/users/#{uid}/media/recent",
      :query=>{access_token:"20779015.1fb234f.30609b83744b49118a56939d1e492ffe", max_id:next_max_id, count:@count})
  end

  def get_uid(username)
    HTTParty.get("https://api.instagram.com/v1/users/search?q=#{username}",
        :query=>{access_token:"20779015.1fb234f.30609b83744b49118a56939d1e492ffe"})["data"].first["id"]
  end

  def import(company, next_max_id=nil)
    if company.instagram_uid.nil?
      uid = self.get_uid(company.instagram_username)
      company.update_attribute(:instagram_uid, uid)
    end

    media = self.get_media(company.instagram_uid, next_max_id)

    media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]
    media["data"].each do |post|
      logger.info "#{company.subdomain} -- existing post?"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
        post = company.posts.create({
          provider:PROVIDER,
          provider_strategy:"username",
          provider_uid:post["id"],
          provider_publication_date:Time.at(post["created_time"].to_i).to_datetime,
          provider_raw_data:JSON.parse(post.to_json),
          media_url:post["images"]["standard_resolution"]["url"],
          media_url_small:post["images"]["low_resolution"]["url"],
          like_count:post["likes"]["count"],
          caption:'#{post["caption"]["text"] if post["caption"]}',
          published:@first_run ? false : company.facebook_auto_publish
         })
        logger.info "#{company.subdomain} -- #{post.id} created"
      end
    end
    if @first_run and next_max_id
      import(company, next_max_id)
    end
  end

end