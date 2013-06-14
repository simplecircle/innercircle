class Vertical < ActiveRecord::Base

  attr_accessible :name

  strip_attributes :only => [:name]

  has_many :companies_verticals
  has_many :companies, through: :companies_verticals
  
end
