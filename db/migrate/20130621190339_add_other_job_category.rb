class AddOtherJobCategory < ActiveRecord::Migration
  def up
    add_column :profiles_company_depts, :other_job_category, :string
    CompanyDept.create(name:"other") if CompanyDept.find_by_name("other").nil?
  end

  def down
    remove_column :profiles_company_depts, :other_job_category
    CompanyDept.find_by_name("other").destroy unless CompanyDept.find_by_name("other").nil?
  end
end
