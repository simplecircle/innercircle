require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :content do
  desc "Import recent provider content"
  task :update => :environment do
    Company.all.order(:name).each do |company|
      puts company.name
      InstagramUsernameWorker.perform_async(company.id) if !company.instagram_username.blank?
      InstagramLocationWorker.perform_async(company.id) if !company.instagram_location_id.blank?
      FoursquareWorker.perform_async(company.id) if !company.foursquare_v2_id.blank?
      FacebookWorker.perform_async(company.id) if !company.facebook.blank?
      TumblrWorker.perform_async(company.id) if !company.tumblr.blank?
    end
  end
  task :send_updates => :environment do
    Company.all.each do |company|
      # company.send_content_update
    end
  end
end

