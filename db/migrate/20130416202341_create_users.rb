class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :full_name
      t.string :role
      t.string :password_digest
      t.integer :company_id

      t.timestamps
    end
    add_index :users, :full_name
    add_index :users, :company_id
  end
end
