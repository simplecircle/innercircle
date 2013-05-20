class AddPendingTagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pending, :boolean, default:false
  end
end