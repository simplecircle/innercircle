class FoursquareWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty
  PROVIDER = "foursquare"

  def perform(company_id, first_run=false)
    if first_run
      @first_run = first_run
      @limit = 200
    else
      @limit = 10
    end
    @offset = 0
    import(Company.find(company_id))
  end

  def get_media(foursquare_v2_id, offset, limit)
    # Foursquare access token are not SUPPOSED to expire.
    HTTParty.get("https://api.foursquare.com/v2/venues/#{foursquare_v2_id}/photos",
      :query=>{oauth_token:Settings.tokens.foursquare, offset:offset, limit:limit})

  end

  def import(company)
    media = self.get_media(company.foursquare_v2_id, @offset, @limit)

    photo_count = media["response"]["photos"]["count"].to_i
    unless media["response"]["photos"]["groups"][1].nil?
      media["response"]["photos"]["groups"][1]["items"].each do |post|
        logger.info "#{company.subdomain} -- existing post?"
        unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
          post = company.posts.create({
            provider:PROVIDER,
            provider_uid:post["id"],
            provider_publication_date:Time.at(post["createdAt"].to_i).to_datetime,
            provider_raw_data:JSON.parse(post.to_json),
            media_url:post["sizes"]["items"][0]["url"],
            media_url_small:post["sizes"]["items"][1]["url"],
            like_count:0,
            published:@first_run ? false : company.foursquare_auto_publish,
            remote_photo_url: @first_run || !company.foursquare_auto_publish ? nil : post["sizes"]["items"][0]["url"]
           })
          logger.info "#{company.subdomain} -- #{post.id} created"
        end
      end
      if @first_run and @offset < photo_count
        @offset += @limit
        import(company)
      end
    end
  end

end