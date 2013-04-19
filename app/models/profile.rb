class Profile < ActiveRecord::Base
  attr_accessible :job_title, :url, :user_id

  belongs_to :user
  has_many :profiles_company_depts
  has_many :company_depts, through: :profiles_company_depts
end
