class Profile < ActiveRecord::Base

  serialize :linkedin_data, Hash
  attr_accessible :first_name, :last_name, :job_title, :url, :user_id, :skills, :linkedin_data, :linkedin_profile

  strip_attributes :only => [:job_title, :first_name, :last_name, :url]

  belongs_to :user
  has_many :profiles_company_depts, :dependent => :destroy
  has_many :company_depts, through: :profiles_company_depts
  after_validation :add_url_protocol

  validates_format_of :url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid", allow_blank:true

  acts_as_taggable_on :skills
  ActsAsTaggableOn.force_lowercase = true

  def full_name
    #always return at least ""
    (self.first_name || "") + (self.last_name.blank? ? "" : " #{self.last_name}")
  end

  def job_category
    return "" if profiles_company_depts.empty?
    category_name = profiles_company_depts.first.company_dept.name
    category_name = profiles_company_depts.first.other_job_category if category_name == "other"
    category_name
  end

  private

  def add_url_protocol
   if self.url.blank?
     self.url = nil
   else
     uri = URI.parse(self.url)
     unless %w( http https ).include?(uri.scheme)
       self.url = 'http://' + self.url
     end
   end
  end
end