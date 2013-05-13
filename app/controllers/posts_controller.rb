class PostsController < ApplicationController

  def new
    companies = Company.all
    companies.each do |company|
      if company.content_instagram_username
        InstagramUsernameWorker.perform_async(company.id)
      end
    end
    render text:"Workers are working"
  end
end
