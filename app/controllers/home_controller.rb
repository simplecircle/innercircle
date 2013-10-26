require 'will_paginate/array'

class HomeController < ApplicationController

  def index
  	if current_user
  	  @posts = Post.following_stream(current_user, 5000).paginate(:page => params[:page], per_page:15)
  	  respond_to do |format|
        format.html {render("user_index")}
        format.js {render("posts/published.js.erb")}
      end
  	else
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
    end
  end
end
