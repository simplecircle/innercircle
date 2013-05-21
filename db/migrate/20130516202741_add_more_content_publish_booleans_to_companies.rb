class AddMoreContentPublishBooleansToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :facebook_auto_publish, :boolean,  default:true
    add_column :companies, :tumblr_auto_publish, :boolean, default:true
    add_column :companies, :twitter_auto_publish, :boolean, default:true
  end
end
