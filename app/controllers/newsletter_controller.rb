class NewsletterController < ApplicationController
  # layout 'marketing'
  def index
    @user = User.new :role=>'talent'
    @user.build_profile
  end
end
