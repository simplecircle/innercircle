class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.column :company_id, :integer
      t.column :provider, :string
      t.column :provider_uid, :string
      t.column :provider_publication_date, :datetime
      t.column :provider_raw_data, :text
      t.column :media_url, :string
      t.column :like_count, :string
      t.column :auto_publish, :boolean
      t.timestamps
    end
    add_index :posts, :company_id
    add_index :posts, :provider_uid
    add_index :posts, :provider_publication_date
  end
end
