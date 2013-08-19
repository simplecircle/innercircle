class StaticController < ApplicationController

  def for_companies
  end

  def robots
    disallowed_subdomains = ['talent']
    if disallowed_subdomains.include? request.subdomain
      robots = File.read(Rails.root + "config/robots.blocked.txt")
    else
      robots = File.read(Rails.root + "config/robots.#{Rails.env}.txt")
    end
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
end