class NewsletterController < ApplicationController
  # layout 'marketing'
  def index
    @user = User.new :role=>'talent'
    @user.build_profile
    @is_kiosk = params[:is_kiosk] == "true"
  end
end
