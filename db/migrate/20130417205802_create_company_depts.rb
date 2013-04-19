class CreateCompanyDepts < ActiveRecord::Migration
  def change
    create_table :company_depts do |t|
      t.string :name
      t.timestamps
    end
  end
end
