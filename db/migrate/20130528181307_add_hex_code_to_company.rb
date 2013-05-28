class AddHexCodeToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :hex_code, :string
  end
end
