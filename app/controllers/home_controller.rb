class HomeController < ApplicationController

  def index
  	if current_user
  	  @posts = Post.following_stream(current_user, 5000)
      render "user_index"
  	else
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
    end
  end
end
