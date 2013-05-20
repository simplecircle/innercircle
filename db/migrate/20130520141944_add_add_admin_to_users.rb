class AddAddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_invite_token, :string
    add_column :users, :admin_invite_sent_at, :datetime
  end
end
