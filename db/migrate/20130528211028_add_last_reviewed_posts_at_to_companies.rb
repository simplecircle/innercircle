class AddLastReviewedPostsAtToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :last_reviewed_posts_at, :datetime
  end
end
