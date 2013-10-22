class Post < ActiveRecord::Base
  serialize :provider_raw_data, Hash
  attr_accessible :provider, :provider_strategy, :provider_uid, :provider_publication_date, :provider_raw_data, :media_url, :media_url_small, :like_count, :published, :caption, :width, :height, :remote_photo_url, :auto_published

  belongs_to :company
  mount_uploader :photo, PhotoUploader
  before_save :check_auto_published

  def self.following_stream(user, limit)
    query = "SELECT p.* FROM posts p
            INNER JOIN relationships r ON r.followed_id = p.company_id
            WHERE (r.follower_id = #{user.id})
            AND (p.published IS TRUE)
            ORDER BY p.created_at DESC
            LIMIT #{limit}"

    Post.find_by_sql(query)
  end
  # def self.following_stream(user, limit)
  #   query = "SELECT p.* FROM posts p
  #           INNER JOIN relationships r ON r.followed_id = p.company_id
  #           WHERE (r.follower_id = #{user.id})
  #           AND (date(r.created_at) - integer '7' <= p.created_at)
  #           AND (p.published IS TRUE)
  #           ORDER BY p.created_at DESC
  #           LIMIT #{limit}"

  #   Post.find_by_sql(query)
  # end

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
  def aspect_ratio
    width > 0 ? height.to_f / width.to_f : 1
  end
  def wrapper_class
    landscape? ? 'landscape' : 'portrait'
  end
  def offset(wrapper_width)
    offset_val = ([aspect_ratio, 1 / aspect_ratio].max * wrapper_width - wrapper_width) / 2
    "#{landscape? ? 'left' : 'top'}:-#{offset_val}px;"
  end
end