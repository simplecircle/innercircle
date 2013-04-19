class CreateProfilesCompanyDepts < ActiveRecord::Migration
  def change
    create_table :profiles_company_depts do |t|
      t.integer :profile_id
      t.integer :company_dept_id
      t.timestamps
    end
    add_index :profiles_company_depts, :profile_id
    add_index :profiles_company_depts, :company_dept_id
  end
end
