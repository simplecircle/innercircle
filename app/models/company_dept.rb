class CompanyDept < ActiveRecord::Base
  attr_accessible :name

  has_many :profiles_company_depts
  has_many :profiles, through: :profiles_company_depts
end
