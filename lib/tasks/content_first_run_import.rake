require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :content do
  desc "Import recent provider content"
  task :first_run_import => :environment do
    Company.all.each do |company|
      puts company.name
      InstagramUsernameWorker.perform_async(company.id, first_run=true) if company.instagram_username
      InstagramLocationWorker.perform_async(company.id, first_run=true) if company.instagram_location_id
      FoursquareWorker.perform_async(company.id, first_run=true) if company.foursquare_v2_id
      FacebookWorker.perform_async(company.id, first_run=true) if company.facebook
      # TumblrWorker.perform_async(company.id, first_run=true) if company.tumblr
    end
  end
end

