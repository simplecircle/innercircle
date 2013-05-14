class PostsController < ApplicationController

  def new
    companies = Company.all
    companies.each do |company|
      if company.instagram_username
        # Call http://jobcrush.local/posts/new?first_run=true when initializing a new company.
        InstagramUsernameWorker.perform_async(company.id, params[:first_run])
      end
    end
    render text:"Workers are working"
  end
end
