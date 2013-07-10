namespace :emails do
  desc "Export emails"
  task :export => :environment do
    require 'CSV'
    CSV.open("#{Rails.root}/email_export.csv", "wb") do |csv|
    	csv << ['email', 'fname', 'lname', 'category', 'companies', 'created_at']
    	User.find_each do |user|
    		p user.email
    		next if !user.talent?
    		csv << [user.email, user.profile.first_name, user.profile.last_name, user.profile.job_category, user.companies.map{|co| co.name}.join(","), user.created_at.in_time_zone("Eastern Time (US & Canada)").to_s]
    	end
    end
  end
end