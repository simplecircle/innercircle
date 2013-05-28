class Post < ActiveRecord::Base
  serialize :provider_raw_data, Hash
  attr_accessible :provider, :provider_strategy, :provider_uid, :provider_publication_date, :provider_raw_data, :media_url, :media_url_small, :like_count, :published, :caption, :width, :height, :remote_photo_url

  belongs_to :company
  mount_uploader :photo, PhotoUploader

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