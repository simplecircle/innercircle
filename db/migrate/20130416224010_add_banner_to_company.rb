class AddBannerToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :banner, :string
  end
end
