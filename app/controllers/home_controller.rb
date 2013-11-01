require 'will_paginate/array'

class HomeController < ApplicationController

  def index
  	if current_user
  	  @posts = Post.following_stream(current_user, 15, home_params[:offset].to_i)
  	  respond_to do |format|
        format.html {render("user_index")}
        format.js {render("posts/published.js.erb")}
      end
  	else
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
    end
  end

  private
  def home_params
    # params.require(:post).permit(:offset, :provider, :provider_strategy, :provider_uid, :provider_publication_date, :provider_raw_data, :media_url, :media_url_small, :like_count, :published, :caption, :width, :height, :remote_photo_url, :auto_published)
    params.permit!
  end
end
