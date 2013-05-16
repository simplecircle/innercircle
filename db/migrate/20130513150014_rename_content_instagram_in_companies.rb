class RenameContentInstagramInCompanies < ActiveRecord::Migration
  def up
    rename_column :companies, :content_instagram, :content_instagram_username
  end

  def down
    rename_column :companies, :content_instagram_username, :content_instagram
  end
end
