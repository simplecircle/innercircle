class Company < ActiveRecord::Base
  attr_accessible :name, :website_url, :users_attributes, :banner
  has_many :users
  accepts_nested_attributes_for :users
  after_validation :add_url_protocol

  mount_uploader :banner, BannerUploader

  validates :name, presence:true
  validates :name, uniqueness:true
  validates :website_url, presence:true
  validates_format_of :website_url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid"
  validates :banner, presence:true

  private

  def add_url_protocol
   if self.website_url.blank?
     self.website_url = nil
   else
     uri = URI.parse(self.website_url)
     unless %w( http https ).include?(uri.scheme)
       self.website_url = 'http://' + self.website_url
     end
   end
  end
end
