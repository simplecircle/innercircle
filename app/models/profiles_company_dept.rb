class ProfilesCompanyDept < ActiveRecord::Base
  attr_accessible :profile_id, :company_dept_id

  belongs_to :company_dept
  belongs_to :profile

end
