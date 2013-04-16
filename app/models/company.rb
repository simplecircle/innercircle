class Company < ActiveRecord::Base
  attr_accessible :name, :website_url, :users_attributes
  has_many :users
  accepts_nested_attributes_for :users

end
