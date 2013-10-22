class AddLinkedinIdentifiersToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :linkedin_identifiers, :text
  end
end
