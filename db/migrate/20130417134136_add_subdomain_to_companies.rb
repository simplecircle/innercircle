class AddSubdomainToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :subdomain, :string
    add_index :companies, :subdomain, unique:true
  end
end
