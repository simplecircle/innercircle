class RelationshipsController < ApplicationController

  before_filter :find_resource

  def create
    if current_user
     if current_user.follow!(@company)
      @size = relationship_params[:size]
      # @follower_count = @company.followers.count
     end
    else
      render "shared/login_overlay"
    end
  end

  def destroy
    if current_user and current_user.following?(@company)
      current_user.unfollow!(@company)
      @size = relationship_params[:size]
      # @follower_count = @company.followers.count
    else
      head 403
    end
  end

  private

  def relationship_params
    params.permit!
  end
  def find_resource
    @company = Company.find(relationship_params[:company_id])
  end
end

