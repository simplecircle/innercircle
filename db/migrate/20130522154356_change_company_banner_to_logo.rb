class ChangeCompanyBannerToLogo < ActiveRecord::Migration
  def change
    rename_column :companies, :banner, :logo
    rename_column :companies, :banner_cache, :logo_cache
  end
end
