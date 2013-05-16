class RenameContentChannelsOnCompanies < ActiveRecord::Migration
  def up
    rename_column :companies, :content_instagram_username, :instagram_username
    rename_column :companies, :content_instagram_uid, :instagram_uid
    rename_column :companies, :content_facebook, :facebook
    rename_column :companies, :content_tumblr, :tumblr
    rename_column :companies, :content_twitter, :twitter
    rename_column :companies, :content_jobs_page, :jobs_page
  end

  def down
    rename_column :companies, :instagram_username, :content_instagram_username
    rename_column :companies, :instagram_uid, :content_instagram_uid
    rename_column :companies, :facebook, :content_facebook
    rename_column :companies, :tumblr, :content_tumblr
    rename_column :companies, :twitter, :content_twitter
    rename_column :companies, :jobs_page, :content_jobs_page
  end
end
