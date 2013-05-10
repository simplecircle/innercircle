class AddLinkedinProfileToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :linkedin_profile, :string
  end
end
