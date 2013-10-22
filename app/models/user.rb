class User < ActiveRecord::Base

  serialize :company_connections, Hash
  attr_accessible :email, :password, :role, :company_dept_ids, :company_connections, :linkedin_access_token

  has_secure_password
  strip_attributes :only => [:email]

  has_many :users_companies, :dependent => :destroy
  has_many :companies, through: :users_companies
  has_many :users_company_depts, :dependent => :destroy
  has_many :company_depts, through: :users_company_depts
  has_one :profile, :dependent => :destroy
  
  accepts_nested_attributes_for :profile, :users_companies
  before_create { generate_token(:auth_token) }
  before_save { self.email = self.email.downcase }

  validates :email, presence:{message:"PLEASE ENTER YOUR EMAIL"}
  validates :email, uniqueness:{message:"THIS EMAIL IS ALREADY TAKEN"}
  validates_format_of :email, with:/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, message:"THIS EMAIL ISN'T VALID"
  validates :company_depts, presence:{message:"CHOOSE AT LEAST ONE FIELD"}
  validates :password, presence:{message:"PLEASE SET YOUR PASSWORD"}
  # password conf is here for password reset functionality.
  # validates_confirmation_of :password, if: :password, message:"Passwords do not match"

  def self.by_category(subdomain, category)
    joins(:companies, :profile => :company_depts).where(role: :talent).where(:companies=>{subdomain: subdomain}).where(:company_depts =>{name: category}).order('email')
  end

  def star_rating(company_id)
    assoc = UsersCompany.find_by_user_id_and_company_id(self.id, company_id)
    assoc.nil? ? nil : assoc.star_rating
  end

  def has_privileges_to(company_id)
    owned_companies.map(&:id).include?(company_id)
  end

  def member_of?(company_id)
    companies.map(&:id).include?(company_id)
  end

  def has_filled_out_profile
    !profile.full_name.empty? && !profile.job_title.blank?
  end

  def owned_companies
    if god?
      return Company.all
    elsif admin?
      return companies
    else
      return []
    end
  end

  def admin?
    role == 'admin'
  end

  def talent?
    role == 'talent'
  end

  def god?
    role == 'god'
  end

  def admin_or_god?
    ['admin', 'god'].include? role
  end

  def god_or_admin?
    ['admin', 'god'].include? role
  end

  def send_password_reset
    set_password_reset_token
    UserMailer.password_reset(self).deliver
  end

  def set_password_reset_token
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
  end

  def send_admin_invite(company)
    generate_token(:admin_invite_token)
    self.admin_invite_sent_at = Time.zone.now
    save!
    UserMailer.admin_invite(self, company).deliver
  end

  def clear_admin_invite_token
    self[:admin_invite_token] = nil
    save!
  end

  def clear_password_reset_token
    self[:password_reset_token] = nil
    save!
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
