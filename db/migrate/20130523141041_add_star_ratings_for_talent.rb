class AddStarRatingsForTalent < ActiveRecord::Migration
  def change
    add_column :users_companies, :star_rating, :integer, default: 0
  end
end
