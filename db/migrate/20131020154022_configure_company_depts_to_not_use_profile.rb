class ConfigureCompanyDeptsToNotUseProfile < ActiveRecord::Migration
  def up
  	rename_column :users_company_depts, :profile_id, :user_id
  	remove_column :users_company_depts, :other_job_category
  end
end
