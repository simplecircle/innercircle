class InstagramLocationWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty

  def perform(company_id, first_run=false)
    @first_run = first_run
    import(company_id)
  end

  def get_media(location_id, next_max_id=nil)
    # develop a sustainable access_token strategy!!!
    HTTParty.get("https://api.instagram.com/v1/locations/#{location_id}/media/recent",
      :query=>{access_token:"20779015.1fb234f.30609b83744b49118a56939d1e492ffe", max_id:next_max_id})
  end

  def import(company_id, next_max_id=nil)
    company = Company.find(company_id)
    media = self.get_media(company.instagram_location_id, next_max_id)
    media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]
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