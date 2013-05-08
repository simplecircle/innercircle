class Profile < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :job_title, :url, :user_id, :skills

  belongs_to :user
  has_many :profiles_company_depts
  has_many :company_depts, through: :profiles_company_depts
  after_validation :add_url_protocol

  validates_format_of :url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid", allow_blank:true

  acts_as_taggable_on :skills
  ActsAsTaggableOn.force_lowercase = true

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
