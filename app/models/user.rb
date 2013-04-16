class User < ActiveRecord::Base
  attr_accessible :company_id, :email, :full_name, :password_digest, :password, :role
  belongs_to :company

  # override has_secure_password forced validation.
  require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation

end
