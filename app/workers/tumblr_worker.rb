class TumblrWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty
  PROVIDER = "tumblr"

  def perform(company_id, first_run=false)
    if first_run
      @first_run = first_run
      # 50 is the max limit Tumblr allows
      @limit = 50
    else
      @limit = 10
    end
    @offset = 0
    import(Company.find(company_id))
  end

  def get_media(blog, offset, limit)
    # Tumblr's access token is not supposed to expire.
    # NOTE: There is a required Tumblr application (Like facebook) for this api key that must exist.
    HTTParty.get("https://api.tumblr.com/v2/blog/#{blog}/posts/photo",
      :query=>{api_key:Settings.tokens.tumblr, offset:offset, limit:limit})
  end

  def import(company)
    media = self.get_media(company.tumblr, @offset, @limit)["response"]
    return if media.blank?

    photo_count = media["blog"]["posts"].to_i
    media["posts"].each do |post|
      logger.info "#{company.subdomain} -- existing post?"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
        new_post = company.posts.new
        new_post.provider = PROVIDER
        new_post.provider_uid = post["id"]
        new_post.provider_publication_date = post["date"]
        new_post.provider_raw_data = JSON.parse(post.to_json)
        new_post.media_url = post["photos"][0]["alt_sizes"][0]["url"]
        new_post.media_url_small = post["photos"][0]["alt_sizes"][0]["url"]
        new_post.media_url_small = !post["photos"][0]["alt_sizes"][3].blank? ? post["photos"][0]["alt_sizes"][3]["url"] : post["photos"][0]["alt_sizes"][2]["url"]
        new_post.like_count = post["note_count"]
        new_post.caption = post["caption"]
        new_post.auto_published = @first_run ? false : company.tumblr_auto_publish
        new_post.published = @first_run ? false : company.tumblr_auto_publish
        new_post.remote_photo_url = @first_run || !company.tumblr_auto_publish ? nil : post["photos"][0]["alt_sizes"][0]["url"]
        new_post.save
        logger.info "#{company.subdomain} -- #{new_post.id} created"
      end
    end
    if @first_run and @offset < photo_count
      @offset += @limit
      import(company)
    end
  end

end