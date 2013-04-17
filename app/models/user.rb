class User < ActiveRecord::Base

  attr_accessible :company_id, :email, :full_name, :password_digest, :password, :role
  attr_accessor :skip_password_validation

  belongs_to :company

  # override has_secure_password forced validation.
  require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

  validates :full_name, presence:true
  validates :email, presence:true
  validates :password, presence:true, unless: :skip_password_validation

end
