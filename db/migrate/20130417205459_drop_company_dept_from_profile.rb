class DropCompanyDeptFromProfile < ActiveRecord::Migration
  def up
    remove_column :profiles, :company_dept
  end

  def down
    add_column :profiles, :company_dept
  end
end
