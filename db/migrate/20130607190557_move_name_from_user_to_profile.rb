class MoveNameFromUserToProfile < ActiveRecord::Migration
  def up
    User.find_each {|u| u.profile.update_attributes(:first_name=>u.first_name, :last_name=>u.last_name) unless u.first_name.nil? && u.last_name.nil? }
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
  def down
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end