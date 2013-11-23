class PostsController < ApplicationController

  before_filter :find_resource, only: [:index]
  # before_filter :authorize

  def update
    @post = Post.find(params[:id])
    @post.remote_photo_url = @post.media_url
    @post.published = true
    @post.company.set_last_published_posts_at
    @post.save
  end

  def index
    @posts = @company.posts.includes(:company).select([:media_url_small, :published, :company_id, :created_at, :id, :provider_publication_date, :provider_strategy, :provider, :width, :height, :caption]).order("provider_publication_date DESC").limit(Company::PAGINATION_LIMIT).offset(post_params[:offset])
    @last_reviewed_time = @company.last_reviewed_posts_at
    @company.update_attribute(:last_reviewed_posts_at, Time.now) if current_user.admin?
    respond_to do |format|
      format.html {render("index")}
      format.js {render("private.js.erb")}
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.update_attribute(:published, false)
  end

  private

  def find_resource
    @company = current_company
  end

  def post_params
    params.permit!
  end
end
