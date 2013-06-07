class Post < ActiveRecord::Base
  serialize :provider_raw_data, Hash
  attr_accessible :provider, :provider_strategy, :provider_uid, :provider_publication_date, :provider_raw_data, :media_url, :media_url_small, :like_count, :published, :caption, :width, :height, :remote_photo_url, :auto_published

  belongs_to :company
  mount_uploader :photo, PhotoUploader
  before_save :check_auto_published

  def check_auto_published
    auto_published = false if published == false
    return true
  end

  def self.import_from_provider(company, providers=Company.provider_fields)
    InstagramUsernameWorker.perform_async(company.id, first_run=true) if !company.instagram_username.blank? && providers.include?('instagram_username')
    InstagramLocationWorker.perform_async(company.id, first_run=true) if !company.instagram_location_id.blank? && providers.include?('instagram_location_id')
    FoursquareWorker.perform_async(company.id, first_run=true) if !company.foursquare_v2_id.blank? && providers.include?('foursquare_v2_id')
    FacebookWorker.perform_async(company.id, first_run=true) if !company.facebook.blank? && providers.include?('facebook')
    TumblrWorker.perform_async(company.id, first_run=true) if !company.tumblr.blank? && providers.include?('tumblr')
  end

  def landscape?
    height < width
  end
  def portrait?
    height > width
  end
  def height_to_width
    width > 0 ? height.to_f / width.to_f : 1
  end
  def wrapper_class
    landscape? ? 'landscape' : 'portrait'
  end
  def offset(wrapper_width)
    offset_val = ([height_to_width, 1 / height_to_width].max * wrapper_width - wrapper_width) / 2
    "#{landscape? ? 'left' : 'top'}:-#{offset_val}px;"
  end
end