class FacebookWorker

  include Sidekiq::Worker
  sidekiq_options retry: false
  include HTTParty
  require 'open-uri'
  PROVIDER = "facebook"

  def perform(company_id, first_run=false)
    if first_run
      @first_run = first_run
      @limit = 200
    else
      @limit = 25
    end
    get_token(company_id)
  end

  def get_token(company_id)
    app_id = Settings.tokens.facebook_app_id
    app_secret = Settings.tokens.facebook_app_secret
    token_url = "https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&grant_type=client_credentials"
    uri = URI.parse(token_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    /access_token=(?<token>.+)/ =~ http.request(request).body
    @access_token =  $1
    import(Company.find(company_id))
  end

  def import(company)
    albums = self.get_albums(company.facebook)
    albums["data"].each{|album| get_media(album["id"], company)}
  end

  def get_albums(page)
    HTTParty.get("https://graph.facebook.com/#{page}/albums", :query=>{access_token:@access_token, limit:@limit})
  end

  def get_media(album, company)
    media = HTTParty.get("https://graph.facebook.com/#{album}/photos", :query=>{access_token:@access_token, limit:@limit})

    if media["data"]
      media["data"].each do |post|
        logger.info "#{company.subdomain} -- existing post?"
        unless Post.select([:provider, :provider_uid]).find_by_provider_and_provider_uid(PROVIDER, post["id"])
          # Occasional fb images won't have the smaller thumb I want. In that case skip em'!
          if post["images"][5]
            post = company.posts.create({
              provider:PROVIDER,
              provider_uid:post["id"],
              provider_publication_date:post["created_time"],
              provider_raw_data:JSON.parse(post.to_json),
              media_url:post["images"].first["source"],
              media_url_small:post["images"][5]["source"],
              like_count:0, #This gets updated when a user publishes an actual photo
              caption:post["name"],
              published:@first_run ? false : company.facebook_auto_publish
             })
            logger.info "#{company.subdomain} -- #{post.id} created"
          end
        end
      end
    end
  end

end