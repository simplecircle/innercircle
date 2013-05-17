class PostsController < ApplicationController

  def new
    companies = Company.all
    companies.each do |company|
      # if company.instagram_username
      #   # Call http://jobcrush.local/posts/new?first_run=true when initializing a new company.
      #   InstagramUsernameWorker.perform_async(company.id, params[:first_run])
      # end
      # if company.instagram_location_id
      #   InstagramLocationWorker.perform_async(company.id, params[:first_run])
      # end
      # if company.foursquare_v2_id
      #   FoursquareWorker.perform_async(company.id, params[:first_run])
      # end
      # if company.facebook
      #   FacebookWorker.perform_async(company.id, params[:first_run])
      # end
    end
    render text:"Workers are working"
  end
end
