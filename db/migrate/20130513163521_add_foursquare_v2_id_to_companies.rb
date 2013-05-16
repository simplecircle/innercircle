class AddFoursquareV2IdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :foursquare_v2_id, :string
  end
end
