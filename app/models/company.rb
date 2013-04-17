class Company < ActiveRecord::Base
  attr_accessible :name, :website_url, :users_attributes, :banner
  has_many :users
  accepts_nested_attributes_for :users

  mount_uploader :banner, BannerUploader

  validates :name, presence:true
  validates :website_url, presence:true
  validates :banner, presence:true
end
