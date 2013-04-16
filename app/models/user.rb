class User < ActiveRecord::Base
  attr_accessible :company_id, :email, :full_name, :password_digest, :role
end
