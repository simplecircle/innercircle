class CompanyDept < ActiveRecord::Base
  # attr_accessible :name

  has_many :users_company_depts
  has_many :users, through: :users_company_depts
end
