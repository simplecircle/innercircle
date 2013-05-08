class AddDescriptionHqAndEmployeeRangeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :short_description, :string, :limit => 80
    add_column :companies, :hq_city, :string
    add_column :companies, :hq_state, :string
    add_column :companies, :employee_count, :string
  end
end
