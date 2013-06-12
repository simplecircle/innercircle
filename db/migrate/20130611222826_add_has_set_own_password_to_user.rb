class AddHasSetOwnPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_set_own_password, :boolean, default: true
  end
end
