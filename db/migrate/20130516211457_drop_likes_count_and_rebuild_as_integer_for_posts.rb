class DropLikesCountAndRebuildAsIntegerForPosts < ActiveRecord::Migration
   def up
    remove_column :posts, :like_count
    add_column :posts, :like_count, :integer, default: 0, :null => false
  end

  def down
     raise ActiveRecord::IrreversibleMigration
  end
end
