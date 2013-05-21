class AddMediaUrlSmallToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :media_url_small, :string
  end
end
