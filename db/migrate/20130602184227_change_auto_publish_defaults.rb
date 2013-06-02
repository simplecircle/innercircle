class ChangeAutoPublishDefaults < ActiveRecord::Migration
  def up
    change_column_default(:companies, :instagram_location_auto_publish, false)
    change_column_default(:companies, :foursquare_auto_publish, false)
  end
  def down
    change_column_default(:companies, :instagram_location_auto_publish, true)
    change_column_default(:companies, :foursquare_auto_publish, true)
  end
end
