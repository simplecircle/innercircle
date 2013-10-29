class RenameCompanyConnectionsToLinkedinConnectionsOnUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :company_connections, :linkedin_connections
  end
end
