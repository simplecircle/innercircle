class AddAutoPublishedFlagToPosts < ActiveRecord::Migration
  def up
    remove_column :posts, :auto_publish
    add_column :posts, :auto_published, :boolean, default:false
  end
  def down
    add_column :posts, :auto_publish, :boolean
    remove_column :posts, :auto_published
  end
end
