class CreateProviderIdentifiers < ActiveRecord::Migration
  def change
    create_table :provider_identifiers do |t|
      t.integer :company_id
      t.string :linkedin
    end
    add_index :provider_identifiers, :linkedin
  end
end
