class HomeController < ApplicationController

  def index
  	if current_user
  	  @posts = Post.following_stream(current_user, Company::PAGINATION_LIMIT, home_params[:offset].to_i)
      @suggested_companies = Company.suggest(3, current_user)
      if home_params[:company_connections_skipped]
        flash[:notice] = "<h4>WELCOME TO YOUR NEWS FEED!</h4><p>It contains the latest content from companies you follow. We started you off by adding a few humdingers. <b>Go ahead, look around...</b></p>"
      end

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
