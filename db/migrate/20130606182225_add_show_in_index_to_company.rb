class AddShowInIndexToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :show_in_index, :boolean, default:true
  end
end
