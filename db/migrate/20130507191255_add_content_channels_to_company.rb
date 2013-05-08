class AddContentChannelsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :content_instagram, :string
    add_column :companies, :content_facebook, :string
    add_column :companies, :content_tumblr, :string
    add_column :companies, :content_twitter, :string
    add_column :companies, :content_jobs_page, :string
  end
end
