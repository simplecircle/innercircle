class RenameProfilesCompanyDepartments < ActiveRecord::Migration
  def up
  	rename_table :profiles_company_depts, :users_company_depts
  end

  def down
  	rename_table  :users_company_depts, :profiles_company_depts 
  end
end
