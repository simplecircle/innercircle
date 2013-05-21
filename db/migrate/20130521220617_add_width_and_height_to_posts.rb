class AddWidthAndHeightToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :width, :integer
    add_column :posts, :height, :integer
  end
end
