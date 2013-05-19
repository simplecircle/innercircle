class Post < ActiveRecord::Base
  serialize :provider_raw_data, Hash
  attr_accessible :provider, :provider_uid, :provider_publication_date, :provider_raw_data, :media_url, :media_url_small, :like_count, :published

  belongs_to :company
end