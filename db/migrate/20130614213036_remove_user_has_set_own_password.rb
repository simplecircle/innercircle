class RemoveUserHasSetOwnPassword < ActiveRecord::Migration
  def change
    remove_column :users, :has_set_own_password
  end
end
