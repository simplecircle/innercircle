class User < ActiveRecord::Base

  attr_accessible :company_id, :email, :first_name, :last_name, :password_digest, :password, :password_confirmation, :role, :profile_attributes

  has_many :users_companies
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
  validates_format_of :email, with:/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, message:"Email isn't valid"
  # These password validations are here for password reset functionality.
  validates_presence_of :password, if: :password
  validates_confirmation_of :password, if: :password

  def self.by_category(subdomain, category)
    joins(:companies, :profile => :company_depts).where(role: :talent).where(:companies=>{subdomain: subdomain}).where(:company_depts =>{name: category}).order(:first_name)
  end

  def owned_companies
    return companies if admin_or_god?
  end

  def god?
    role == 'god'
  end

  def admin_or_god?
    ['admin', 'god'].include? role
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
