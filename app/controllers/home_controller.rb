class HomeController < ApplicationController

  layout 'marketing'

  def index
  	if current_user
  	else
      @companies = Company.where(:show_in_index=>true).order('last_published_posts_at DESC')
    end
  end
end
