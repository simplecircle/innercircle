class AddRemotePhotoUrlToPost < ActiveRecord::Migration
  def change
    add_column :posts, :remote_photo_url, :string
  end
end
