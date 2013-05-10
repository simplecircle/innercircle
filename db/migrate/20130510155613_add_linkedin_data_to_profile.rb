class AddLinkedinDataToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :linkedin_data, :text
  end
end
