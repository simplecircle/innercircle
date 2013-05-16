class AddContentInstagramUidToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :content_instagram_uid, :string
  end
end
