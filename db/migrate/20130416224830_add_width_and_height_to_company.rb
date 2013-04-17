class AddWidthAndHeightToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :width, :integer
    add_column :companies, :height, :integer
  end
end
