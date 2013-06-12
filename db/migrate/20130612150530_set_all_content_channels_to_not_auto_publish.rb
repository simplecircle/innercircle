class SetAllContentChannelsToNotAutoPublish < ActiveRecord::Migration
  def change
    change_column_default(:companies, :instagram_username_auto_publish, false)
    change_column_default(:companies, :facebook_auto_publish, false)
    change_column_default(:companies, :tumblr_auto_publish, false)
    change_column_default(:companies, :twitter_auto_publish, false)
  end
end
