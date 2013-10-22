class AddLinkedinAccessTokenAndCompanyConnectionsHash < ActiveRecord::Migration
  def change
    add_column :users, :linkedin_access_token, :string
    add_column :users, :company_connections, :text
  end
end
