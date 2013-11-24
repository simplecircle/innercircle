class Admin::PostsController < ApplicationController

  # before_filter :authorize

  def index
    @posts = Post.includes(:company).select([:media_url_small, :published, :company_id, :created_at, :id, :provider_publication_date, :provider_strategy, :provider, :width, :height, :caption]).order("provider_publication_date DESC").limit(Company::PAGINATION_LIMIT).offset(post_params[:offset])
    respond_to do |format|
      format.html {render("index")}
      format.js {render("posts/private.js.erb")}
    end
  end

  private

  def post_params
    params.permit!
  end
end
