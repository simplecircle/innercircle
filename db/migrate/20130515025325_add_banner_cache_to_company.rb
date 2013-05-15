class AddBannerCacheToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :banner_cache, :string
  end
end
