class Profile < ActiveRecord::Base
  attr_accessible :job_title, :url, :user_id, :skills

  belongs_to :user
  has_many :profiles_company_depts
  has_many :company_depts, through: :profiles_company_depts

  acts_as_taggable_on :skills

end
