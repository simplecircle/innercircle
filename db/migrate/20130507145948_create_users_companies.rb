class CreateUsersCompanies < ActiveRecord::Migration
  def change
    create_table :users_companies do |t|
      t.integer :user_id
      t.integer :company_id

      t.timestamps
    end
    add_index :users_companies, :user_id
    add_index :users_companies, :company_id
  end
end
