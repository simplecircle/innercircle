class InstagramLocationWorker

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

  def get_media(location_id, next_max_id=nil)
    # IG's access_token doesn't have an expiration date.
    HTTParty.get("https://api.instagram.com/v1/locations/#{location_id}/media/recent",
      :query=>{access_token:Settings.tokens.instagram, max_id:next_max_id, count:@count})
  end

  def import(company, next_max_id=nil)
    media = self.get_media(company.instagram_location_id, next_max_id)

    media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]
    media["data"].each do |post|
      logger.info "#{company.subdomain} -- existing post?"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
        new_post = company.posts.new
        new_post.provider = PROVIDER
        new_post.provider_strategy = "location"
        new_post.provider_uid = post["id"]
        new_post.provider_publication_date = Time.at(post["created_time"].to_i).to_datetime
        new_post.provider_raw_data = JSON.parse(post.to_json)
        new_post.media_url = post["images"]["standard_resolution"]["url"]
        new_post.media_url_small = post["images"]["low_resolution"]["url"]
        new_post.like_count = post["likes"]["count"]
        new_post.caption = post["caption"]["text"] if post["caption"]
        new_post.auto_published = @first_run ? false : company.instagram_location_auto_publish
        new_post.published = @first_run ? false : company.instagram_location_auto_publish
        new_post.remote_photo_url = @first_run || !company.instagram_location_auto_publish ? nil : post["images"]["standard_resolution"]["url"]
        new_post.save!
        logger.info "#{company.subdomain} -- #{new_post.id} created"
      end
    end
    if @first_run and next_max_id
      import(company, next_max_id)
    end
  end

end