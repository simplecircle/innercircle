class AddReferralSourceToUser < ActiveRecord::Migration
  def change
  	add_column :users, :referral_source, :text
  end
end
