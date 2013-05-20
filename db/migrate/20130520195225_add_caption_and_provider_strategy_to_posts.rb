class AddCaptionAndProviderStrategyToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :caption, :text, null:true
    add_column :posts, :provider_strategy, :string, default:"default"
  end
end
