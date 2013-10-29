class UsersCompanyDept < ActiveRecord::Base
  # attr_accessible :profile_id, :company_dept_id, :other_job_category

  belongs_to :company_dept
  belongs_to :user

end