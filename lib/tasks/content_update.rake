require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :content do
  desc "Import recent provider content"
  task :update => :environment do
    Company.all.each do |company|
      InstagramUsernameWorker.perform_async(company.id) if company.instagram_username
      InstagramLocationWorker.perform_async(company.id) if company.instagram_location_id
      FoursquareWorker.perform_async(company.id) if company.foursquare_v2_id
      FacebookWorker.perform_async(company.id) if company.facebook
      TumblrWorker.perform_async(company.id) if company.tumblr
    end
  end
end

