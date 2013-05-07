class User < ActiveRecord::Base

  attr_accessible :company_id, :email, :first_name, :last_name, :password_digest, :password, :role, :profile_attributes

  has_many :users_companies
  has_many :companies, through: :users_companies
  has_one :profile
  accepts_nested_attributes_for :profile

  # override has_secure_password forced validation.
  require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

  validates :first_name, presence:true
  validates :last_name, presence:true
  validates :email, presence:true
  validates :email, uniqueness:true
  validates_format_of :email, with:/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, message:"Email isn't valid"
  validates :password, presence:true

  def self.by_category(subdomain, category)
    joins(:companies, :profile => :company_depts).where(role: :talent).where(:companies=>{subdomain: subdomain}).where(:company_depts =>{name: category}).order(:first_name)
    # This worked before users and company became has_many
    # joins(:company, :profile => :company_depts).where(role: :talent).where(:companies=>{subdomain: subdomain}).where(:company_depts =>{name: category}).order(:first_name)
  end


end
