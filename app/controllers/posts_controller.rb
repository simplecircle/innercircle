class PostsController < ApplicationController

  before_filter :find_resource, only: [:index]
  before_filter :authorize

  def new_from_provider
    company = Company.find_by_subdomain!(request.subdomain)
    InstagramUsernameWorker.perform_async(company.id, first_run=true) if company.instagram_username
    InstagramLocationWorker.perform_async(company.id, first_run=true) if company.instagram_location_id
    FoursquareWorker.perform_async(company.id, first_run=true) if company.foursquare_v2_id
    FacebookWorker.perform_async(company.id, first_run=true) if company.facebook
    TumblrWorker.perform_async(company.id, first_run=true) if company.tumblr
    redirect_to posts_url(subdomain: company.subdomain)
  end

  def update
    @post = Post.find(params[:id])
    @post.photo = URLTempfile.new(@post.media_url, Dir.tmpdir, encoding:'ascii-8bit')
    if @post.provider == "facebook"
      @access_token = "CAABnZC9SmhE4BACO4oLv15wZCWyhmhNUcBJek9ypNGpKWJGR6oEs2v1P8vibAP0qmsO96mkIaD0EjlxZCEvLTURZAnW6P9ZBMMuZBcTua5k0lKZA0RZAO805GzR6NBCun4ExQDENWM1ySDFTMgVmRpTo3mBEIZBLBZCh1wZCQp4iELYyQDyVx1S43ZC1"
      fql = URI::encode("select like_info from photo where object_id=")
      fql_response = HTTParty.get("https://graph.facebook.com/fql?q=#{fql}#{@post.provider_uid}", :query=>{access_token:@access_token})
      @post.like_count = fql_response["data"].first["like_info"]["like_count"].to_i
    end
    @post.published = true
    @post.save
  end

  def index
    @posts = @company.posts.includes(:company).select([:media_url_small, :published, :company_id, :id, :provider_publication_date, :provider_strategy, :provider]).order("provider_publication_date DESC").paginate(:page => params[:page], per_page:32)
    respond_to do |format|
        format.html {render("index")}
        format.js {render("index.js.erb")}
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.update_attribute(:published, false)
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end
end
