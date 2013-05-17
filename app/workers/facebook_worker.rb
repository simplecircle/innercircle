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
      @limit = 10
    end
    import(Company.find(company_id))
  end

  def get_albums(page)
    HTTParty.get("https://graph.facebook.com/#{page}/albums",
      :query=>{access_token:"CAABnZC9SmhE4BACO4oLv15wZCWyhmhNUcBJek9ypNGpKWJGR6oEs2v1P8vibAP0qmsO96mkIaD0EjlxZCEvLTURZAnW6P9ZBMMuZBcTua5k0lKZA0RZAO805GzR6NBCun4ExQDENWM1ySDFTMgVmRpTo3mBEIZBLBZCh1wZCQp4iELYyQDyVx1S43ZC1", limit:@limit})
  end

  def get_media(album, company)
    media = HTTParty.get("https://graph.facebook.com/#{album}/photos",
      :query=>{access_token:"CAABnZC9SmhE4BACO4oLv15wZCWyhmhNUcBJek9ypNGpKWJGR6oEs2v1P8vibAP0qmsO96mkIaD0EjlxZCEvLTURZAnW6P9ZBMMuZBcTua5k0lKZA0RZAO805GzR6NBCun4ExQDENWM1ySDFTMgVmRpTo3mBEIZBLBZCh1wZCQp4iELYyQDyVx1S43ZC1", limit:@limit})
    media["data"].each do |post|
      logger.info "check if post exists"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
        fql = URI::encode("select like_info from photo where object_id=")
        fql_response = HTTParty.get("https://graph.facebook.com/fql?q=#{fql}#{post['id']}",
         :query=>{access_token:"CAABnZC9SmhE4BACO4oLv15wZCWyhmhNUcBJek9ypNGpKWJGR6oEs2v1P8vibAP0qmsO96mkIaD0EjlxZCEvLTURZAnW6P9ZBMMuZBcTua5k0lKZA0RZAO805GzR6NBCun4ExQDENWM1ySDFTMgVmRpTo3mBEIZBLBZCh1wZCQp4iELYyQDyVx1S43ZC1"})

        post = Post.create({
          provider:PROVIDER,
          provider_uid:post["id"],
          provider_publication_date:post["created_time"],
          provider_raw_data:JSON.parse(post.to_json),
          media_url:post["images"].first["source"],
          like_count:fql_response["data"].first["like_info"]["like_count"].to_i,
          published:company.facebook_auto_publish
         })
        logger.info "Post #{post.id} created"
      end
    end
  end

  def import(company)
    albums = self.get_albums(company.facebook)
    albums["data"].each{|album| get_media(album["id"], company)}
    # media = self.get_media(company.facebook)

    # media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]
    # media["data"].each do |post|
    #   logger.info "check if post exists"
    #   unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
    #     post = Post.create({
    #       provider:PROVIDER,
    #       provider_uid:post["id"],
    #       provider_publication_date:Time.at(post["created_time"].to_i).to_datetime,
    #       provider_raw_data:JSON.parse(post.to_json),
    #       media_url:post["images"]["standard_resolution"]["url"],
    #       like_count:post["likes"]["count"],
    #       published:company.instagram_username_auto_publish
    #      })
    #     logger.info "Post #{post.id} created"
    #   end
    # end
    # if @first_run and next_max_id
    #   import(company, next_max_id)
    # end
  end

end