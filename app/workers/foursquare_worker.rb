class FoursquareWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty

  def perform(company_id, first_run=false)
    @first_run = first_run
    import(company_id)
  end

  def get_media(foursquare_v2_id, next_max_id=nil)
    # develop a sustainable access_token strategy!!!
    media = HTTParty.get("https://api.foursquare.com/v2/venues/#{foursquare_v2_id}/photos",
      :query=>{oauth_token:"NDY4W2WJO2SW5PVDFYP4NEAOEM5LWKVTAEDYSAQPRHMO0XAV", offset:0, limit:700})
    logger.info media.to_yaml
    # media["response"]["photos"]["groups"][1]["items"][0] #.each{|item| p item}
    # media["response"]["photos"]["groups"][1]["items"][0]["sizes"]["items"][0]["url"]
    # media["response"]["photos"]["groups"][1]["items"].each{|item| p item["createdAt"]}
  end

  def import(company_id, next_max_id=nil)
    company = Company.find(company_id)
    media = self.get_media(company.foursquare_v2_id, next_max_id)
    logger.info "=========================================================="
    # media["pagination"].empty? ? next_max_id = nil : next_max_id = media["pagination"]["next_max_id"]

    media["response"]["photos"]["groups"][1]["items"].each do |post|
      logger.info "check if post exists"
      unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid("foursquare", post["id"])
        post = Post.create({
          provider:"foursquare",
          provider_uid:post["id"],
          provider_publication_date:Time.at(post["createdAt"].to_i).to_datetime,
          provider_raw_data:JSON.parse(post.to_json),
          media_url:post["sizes"]["items"][0]["url"],
          like_count:nil,
          published:company.instagram_username_auto_publish
         })
        logger.info "Post #{post.id} created"
      end
    end
    # if @first_run == "true"
    #   unless next_max_id.nil?
    #     import(company_id, next_max_id)
    #   end
    # end
  end

end