class FacebookWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty
  require 'open-uri'
  PROVIDER = "facebook"

  def perform(company_id, first_run=false)
    if first_run
      @first_run = true
      @limit = 200
    else
      @limit = 25
    end
    @access_token = "CAABnZC9SmhE4BACO4oLv15wZCWyhmhNUcBJek9ypNGpKWJGR6oEs2v1P8vibAP0qmsO96mkIaD0EjlxZCEvLTURZAnW6P9ZBMMuZBcTua5k0lKZA0RZAO805GzR6NBCun4ExQDENWM1ySDFTMgVmRpTo3mBEIZBLBZCh1wZCQp4iELYyQDyVx1S43ZC1"
    import(Company.find(company_id))
  end

  def get_albums(page)
    HTTParty.get("https://graph.facebook.com/#{page}/albums",
      :query=>{access_token:@access_token, limit:@limit})
  end

  def get_media(album, company)
    media = HTTParty.get("https://graph.facebook.com/#{album}/photos",
      :query=>{access_token:@access_token, limit:@limit})

    if media["data"]
      media["data"].each do |post|
        logger.info "check if post exists"
        unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
          post = company.posts.create({
            provider:PROVIDER,
            provider_uid:post["id"],
            provider_publication_date:post["created_time"],
            provider_raw_data:JSON.parse(post.to_json),
            media_url:post["images"].first["source"],
            media_url_small:post["images"][5]["source"],
            like_count:0, #This gets updated when a user publishes an actual photo
            published:@first_run ? false : company.facebook_auto_publish
           })
          logger.info "Post #{post.id} created"
        end
      end
    end
  end

  def import(company)
    albums = self.get_albums(company.facebook)
    albums["data"].each{|album| get_media(album["id"], company)}
  end

end