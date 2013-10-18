class HomeController < ApplicationController

  def index
  	if current_user
  		  # this is just temp for now.
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
  	else
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
    end
  end
end
