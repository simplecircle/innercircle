class RemoveHeightAndWidthFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :width
    remove_column :companies, :height
  end
end
