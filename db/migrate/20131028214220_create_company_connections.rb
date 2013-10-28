class CreateCompanyConnections < ActiveRecord::Migration
  def change
    create_table :company_connections do |t|
      t.integer :user_id
      t.integer :company_id

      t.timestamps
    end
    add_index :company_connections, :user_id
    add_index :company_connections, :company_id
  end
end
