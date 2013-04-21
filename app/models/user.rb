class User < ActiveRecord::Base

  attr_accessible :company_id, :email, :full_name, :password_digest, :password, :role, :profile_attributes

  belongs_to :company
  has_one :profile
  accepts_nested_attributes_for :profile

  # override has_secure_password forced validation.
  require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

  validates :full_name, presence:true
  validates :email, presence:true
  validates :email, uniqueness:true
  validates_format_of :email, with:/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i, message:"Email isn't valid"
  validates :password, presence:true

  def self.by_category(subdomain, category)
    joins(:company, :profile => :company_depts).where(role: :talent).where(:companies=>{subdomain: subdomain}).where(:company_depts =>{name: category}).order(:full_name)
  end


end
