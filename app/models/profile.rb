class Profile < ActiveRecord::Base
  attr_accessible :job_title, :url, :user_id, :skills

  belongs_to :user
  has_many :profiles_company_depts
  has_many :company_depts, through: :profiles_company_depts

  validates_format_of :url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid", allow_blank:true

  acts_as_taggable_on :skills

end
