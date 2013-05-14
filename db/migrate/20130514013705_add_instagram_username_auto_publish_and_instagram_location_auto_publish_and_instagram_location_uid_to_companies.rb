class AddInstagramUsernameAutoPublishAndInstagramLocationAutoPublishAndInstagramLocationUidToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :instagram_username_auto_publish, :boolean, default:true
    add_column :companies, :instagram_location_auto_publish, :boolean, default:true
    add_column :companies, :instagram_location_id, :string
  end
end
