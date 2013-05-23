class UsersCompany < ActiveRecord::Base
  attr_accessible :company_id, :user_id, :star_rating

  belongs_to :user
  belongs_to :company
end
