class Company < ActiveRecord::Base

  attr_accessible :name, :website_url, :users_attributes, :banner, :short_description, :hq_city, :hq_state, :employee_count, :verticals, :content_instagram, :content_facebook, :content_tumblr, :content_twitter, :content_jobs_page

  has_many :users_companies
  has_many :users, through: :users_companies
  has_many :companies_verticals
  has_many :verticals, through: :companies_verticals
  accepts_nested_attributes_for :users, :users_companies
  after_validation :add_url_protocol
  mount_uploader :banner, BannerUploader


  validates :name, presence:true
  validates :name, uniqueness:true
  validates :website_url, presence:true
  validates :short_description, presence:true
  validates :hq_city, presence:true
  validates_format_of :employee_count, with:/^[\d]+_[\d]+$/, message:"please select a range"
  validates_format_of :hq_state, with:/^[A-Z]{2}$/, message:"please select a state"
  validates_format_of :website_url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid"
  validates :banner, presence:true

  private

  def self.employee_counts
    [["Select a range", ""], ["0 - 10", "0_10"], ["11 - 50", "11_50"], ["51 - 100", "51_100"], ["101 - 250", "101_250"], ["251 - 500", "251_500"], ["500+", "500_9999"]]
  end

  def self.states
     [['State',''],['Alabama', 'AL'],['Alaska', 'AK'],['Arizona', 'AZ'],['Arkansas', 'AR'],['California', 'CA'],['Colorado', 'CO'],['Connecticut', 'CT'],['Delaware', 'DE'],['District Of Columbia', 'DC'],['Florida', 'FL'],['Georgia', 'GA'],['Hawaii', 'HI'],['Idaho', 'ID'],['Illinois', 'IL'],['Indiana', 'IN'],['Iowa', 'IA'],['Kansas', 'KS'],['Kentucky', 'KY'],['Louisiana', 'LA'],['Maine', 'ME'],['Maryland', 'MD'],['Massachusetts', 'MA'],['Michigan', 'MI'],['Minnesota', 'MN'],['Mississippi', 'MS'],['Missouri', 'MO'],['Montana', 'MT'],['Nebraska', 'NE'],['Nevada', 'NV'],['New Hampshire', 'NH'],['New Jersey', 'NJ'],['New Mexico', 'NM'],['New York', 'NY'],['North Carolina', 'NC'],['North Dakota', 'ND'],['Ohio', 'OH'],['Oklahoma', 'OK'],['Oregon', 'OR'],['Pennsylvania', 'PA'],['Rhode Island', 'RI'],['South Carolina', 'SC'],['South Dakota', 'SD'],['Tennessee', 'TN'],['Texas', 'TX'],['Utah', 'UT'],['Vermont', 'VT'],['Virginia', 'VA'],['Washington', 'WA'],['West Virginia', 'WV'],['Wisconsin', 'WI'],['Wyoming', 'WY']]
   end

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
