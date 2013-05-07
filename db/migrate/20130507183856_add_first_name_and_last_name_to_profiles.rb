class AddFirstNameAndLastNameToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :first_name, :string
    add_column :profiles, :last_name, :string
    add_index :profiles, :first_name
    add_index :profiles, :last_name
  end
end
