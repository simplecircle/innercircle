class DropLinkedinIdentifiersFromCompanies < ActiveRecord::Migration
  def change
  	remove_column :companies, :linkedin_identifiers
  end
end
