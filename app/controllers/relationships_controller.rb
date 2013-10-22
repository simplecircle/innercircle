class RelationshipsController < ApplicationController

  # before_filter :find_resource, except:"suggest"

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
      @follower_count = @company.followers.count
    else
      head 403
    end
  end

  # def suggest
  #   @ps_friends = []
  #   @same_breed = []
  #   @most_active_pups = []
  #   @fan = true if params[:fan] == "t"
  #   @onboarding = false if params[:onboarding] == "f"

  #   if cookies.signed[:fb_token]
  #     Koala::Facebook::API.new(cookies.signed[:fb_token]).get_connections("me", "friends").each do |friend|
  #       if ps_friend = User.find_by_fbuid(friend["id"])
  #         ps_friend.streams.each do |stream|
  #           @ps_friends << stream
  #           @ps_friends.sort! { |a,b| a.name.downcase <=> b.name.downcase }
  #         end
  #       end
  #     end
  #   end

  #   unless current_user.streams.blank?
  #     Stream.same_breed(current_user.streams.first.breed).each do |stream|
  #       @same_breed << stream unless @ps_friends.include?(stream)
  #     end
  #   end

  #   most_active = Stream.most_active
  #   # This empty? condit is here so that things won't blow up in DEV if there's no posts in the last 7 days!
  #   unless most_active.empty?
  #     most_active.each do |stream|
  #       unless @ps_friends.include?(stream) or @same_breed.include?(stream)
  #         @most_active_pups << stream
  #         current_user.follow!(stream) unless current_user.following?(stream)
  #       end
  #     end
  #   end
  # end

  private

  # def find_resource
  #   @stream = Stream.find(params[:stream_id])
  # end
end

