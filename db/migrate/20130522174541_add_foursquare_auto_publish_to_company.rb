class AddFoursquareAutoPublishToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :foursquare_auto_publish, :boolean, default:true
  end
end
