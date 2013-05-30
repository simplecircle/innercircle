class AddLastPublishedPostsAtToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :last_published_posts_at, :datetime, :default => Time.at(0)
  end
end
