class CreateCompaniesVerticals < ActiveRecord::Migration
  def change
    create_table :companies_verticals do |t|
      t.integer :company_id
      t.integer :vertical_id

      t.timestamps
    end
    add_index :companies_verticals, :company_id
    add_index :companies_verticals, :vertical_id
  end
end
