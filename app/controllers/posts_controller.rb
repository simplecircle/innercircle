class PostsController < ApplicationController

  before_filter :find_resource, only: [:index]

  def new
    companies = Company.all
    companies.each do |company|
      if company.instagram_username
        # Call http://jobcrush.local/posts/new?first_run=true when initializing a new company.
        InstagramUsernameWorker.perform_async(company.id, params[:first_run])
      end
      if company.instagram_location_id
        InstagramLocationWorker.perform_async(company.id, params[:first_run])
      end
      if company.foursquare_v2_id
        FoursquareWorker.perform_async(company.id, params[:first_run])
      end
      if company.facebook
        FacebookWorker.perform_async(company.id, params[:first_run])
      end
      # if company.tumblr
      #   TumblrWorker.perform_async(company.id, params[:first_run])
      # end
    end
    render text:"Workers are working"
  end

  def index
    @posts = @company.posts.order("provider_publication_date DESC")
  end

  private

  def find_resource
    @company = Company.find_by_subdomain!(request.subdomain)
  end
end
