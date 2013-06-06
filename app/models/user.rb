class User < ActiveRecord::Base

  attr_accessible :company_id, :email, :first_name, :last_name, :password_digest, :password, :password_confirmation, :role, :profile_attributes, :pending

  has_many :users_companies, :dependent => :destroy
  has_many :companies, through: :users_companies
  has_one :profile, :dependent => :destroy
  
  accepts_nested_attributes_for :profile, :users_companies
  before_create { generate_token(:auth_token) }

  # override has_secure_password forced validation.
  require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

  validates :email, presence:true
  validates :email, uniqueness:true
  validates_format_of :email, with:/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, message:"Email isn't valid. Please make sure there are no spaces"
  # These password validations are here for password reset functionality.
  validates_presence_of :password, if: :password
  validates_confirmation_of :password, if: :password, message:"Passwords do not match"

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
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
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
