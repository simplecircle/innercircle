class Company < ActiveRecord::Base

  # attr_accessible :name, :website_url, :users_attributes, :logo, :logo_cache, :short_description, :hq_city, :hq_state, :employee_count, :verticals, :instagram_username, :facebook, :tumblr, :twitter, :jobs_page, :instagram_username_auto_publish, :instagram_location_auto_publish, :facebook_auto_publish, :tumblr_auto_publish, :twitter_auto_publish, :foursquare_auto_publish, :foursquare_v2_id, :instagram_uid, :hex_code, :last_reviewed_posts_at, :last_published_posts_at, :instagram_location_id, :show_in_index, :linkedin_identifiers
  strip_attributes :only => [:name, :website_url, :short_description, :hq_city, :instagram_username, :facebook, :tumblr, :twitter, :jobs_page, :foursquare_v2_id, :instagram_uid, :hex_code, :instagram_location_id]

  has_many :users_companies, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :users, through: :users_companies
  has_many :companies_verticals, :dependent => :destroy
  has_many :verticals, through: :companies_verticals
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :company_connections
  has_many :connected_users, :through => :company_connections, :source=>:user
  has_many :provider_identifiers

  before_create :set_last_reviewed_posts_at
  accepts_nested_attributes_for :users, :users_companies, :provider_identifiers
  after_validation :add_url_protocol
  after_update :update_provider_content
  after_commit :create_provider_content, on: :create
  mount_uploader :logo, LogoUploader

  before_validation :add_hash_symbol_to_hex_code
  validate :validate_hex_code
  validates :name, presence:true
  validates :name, uniqueness:true
  validates :website_url, presence:true
  validates :short_description, presence:true
  validates :hq_city, presence:true
  validates_format_of :employee_count, with:/\A[\d]+_[\d]+\z/, message:"please select a range"
  validates_format_of :hq_state, with:/\A[A-Z]{2}\z/, message:"please select a state"
  validates_format_of :website_url, with:/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}?/, message:"URL isn't valid"
  validates :logo, presence:true

  def admins
    users.where(:role=>"admin")
  end

  def create_provider_content
    Post.import_from_provider(self)
  end

  def self.provider_fields
    ["foursquare_v2_id", "facebook", "tumblr", "instagram_location_id", "instagram_username"]
  end

  def update_provider_content
    changed_providers = []
    self.changes.each do |field, change|
      changed_providers << field if !change[1].blank? && Company.provider_fields.include?(field)
    end
    Post.import_from_provider(self, changed_providers) unless changed_providers.length == 0
  end

  def create_default_admin_user
    default_admin_user_email = "#{self.subdomain}@getinnercircle.com"
    if User.find_by_email(default_admin_user_email).nil?
      default_admin_user = self.users.build(role:"admin", email:default_admin_user_email, password:"#{self.subdomain}#{self.id}")
      default_admin_user.build_profile
      self.users << default_admin_user
    end
  end

  def last_published_time
    return "" if last_published_posts_at.nil?

    minutes = ((Time.now - last_published_posts_at) / 60).to_i
    if minutes == 0
      return "just now"
    elsif minutes < 60
      return "#{minutes}min"
    elsif minutes < 1440
      hours = (minutes/60)
      return "#{hours}hr#{'s' unless hours==1}"
    elsif minutes < 1440 * 6
      days = (minutes / 1440)
      return "#{days}day#{'s' unless days==1}"
    else
      return last_published_posts_at.strftime("%b %e")
    end
  end

  def latest_posts_by_publish_date(count=3)
    posts.where(:published=>true).order("updated_at DESC").select([:company_id, :id, :provider_publication_date, :provider_strategy, :provider, :height, :width, :photo]).limit(count)
  end

  def latest_posts_by_provider_date(count=3)
    posts.where(:published=>true).order("provider_publication_date DESC").select([:company_id, :id, :provider_publication_date, :provider_strategy, :provider, :height, :width, :photo]).limit(count)
  end

  def posts_to_review_count(since = last_reviewed_posts_at)
    posts.where(:published=>false).where('posts.created_at > ?', since).count
  end

  def posts_auto_published_count(since = 1.day.ago)
    posts.where(:auto_published=>true).where('posts.created_at > ?', since).count
  end

  def send_content_update
    admins.each {|admin| UserMailer.content_update(admin, self).deliver }
  end

  def set_last_published_posts_at
    self.update_attribute(:last_published_posts_at, Time.now)
  end

  def set_last_reviewed_posts_at
    self.last_reviewed_posts_at = Time.now
  end

  private

  def validate_hex_code
    return if hex_code.blank?
    if hex_code.match(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/).nil?
      errors.add(:hex_code, "Hex code must be between #000000 and #FFFFFF")
    end
  end

  def add_hash_symbol_to_hex_code
    if !self.hex_code.blank? && self.hex_code.match(/\#/).nil?
      self.hex_code = "#" + self.hex_code
    end
  end

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

    if self.jobs_page.blank?
      self.jobs_page = nil
    else
      uri = URI.parse(self.jobs_page)
      unless %w( http https ).include?(uri.scheme)
        self.jobs_page = 'http://' + self.jobs_page
      end
    end
  end

  def self.suggest(quantity, current_user)
    following_ids = current_user.following_ids
    co_ids = ids.reject{|id| following_ids.include?(id)}
    select(:name, :id, :subdomain, :short_description).find(co_ids.sample(quantity))
  end
end
