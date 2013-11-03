class RelationshipsController < ApplicationController

  before_filter :find_resource

  def create
    if current_user
     if current_user.follow!(@company)
      # @follower_count = @company.followers.count
     end
    else
      render "shared/login_overlay"
    end
  end

  def destroy
    if current_user and current_user.following?(@company)
      current_user.unfollow!(@company)
      # @follower_count = @company.followers.count
    else
      head 403
    end
  end

  private

  def find_resource
    @company = Company.find(params[:company_id])
  end
end

