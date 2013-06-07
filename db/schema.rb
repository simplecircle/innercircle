# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130607162049) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "website_url"
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
    t.string   "logo"
    t.string   "subdomain"
    t.string   "instagram_username"
    t.string   "facebook"
    t.string   "tumblr"
    t.string   "twitter"
    t.string   "jobs_page"
    t.string   "short_description",               :limit => 80
    t.string   "hq_city"
    t.string   "hq_state"
    t.string   "employee_count"
    t.string   "foursquare_v2_id"
    t.string   "instagram_uid"
    t.boolean  "instagram_username_auto_publish",               :default => true
    t.boolean  "instagram_location_auto_publish",               :default => false
    t.string   "instagram_location_id"
    t.string   "logo_cache"
    t.boolean  "facebook_auto_publish",                         :default => true
    t.boolean  "tumblr_auto_publish",                           :default => true
    t.boolean  "twitter_auto_publish",                          :default => true
    t.boolean  "foursquare_auto_publish",                       :default => false
    t.string   "hex_code"
    t.datetime "last_reviewed_posts_at"
    t.datetime "last_published_posts_at",                       :default => '1970-01-01 00:00:00'
    t.boolean  "show_in_index",                                 :default => true
  end

  add_index "companies", ["subdomain"], :name => "index_companies_on_subdomain", :unique => true

  create_table "companies_verticals", :force => true do |t|
    t.integer  "company_id"
    t.integer  "vertical_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "companies_verticals", ["company_id"], :name => "index_companies_verticals_on_company_id"
  add_index "companies_verticals", ["vertical_id"], :name => "index_companies_verticals_on_vertical_id"

  create_table "company_depts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "company_id"
    t.string   "provider"
    t.string   "provider_uid"
    t.datetime "provider_publication_date"
    t.text     "provider_raw_data"
    t.string   "media_url"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.boolean  "published",                 :default => true
    t.integer  "like_count",                :default => 0,         :null => false
    t.string   "media_url_small"
    t.text     "caption"
    t.string   "provider_strategy",         :default => "default"
    t.string   "photo"
    t.integer  "width"
    t.integer  "height"
    t.string   "remote_photo_url"
    t.boolean  "auto_published",            :default => false
  end

  add_index "posts", ["company_id"], :name => "index_posts_on_company_id"
  add_index "posts", ["provider_publication_date"], :name => "index_posts_on_provider_publication_date"
  add_index "posts", ["provider_uid"], :name => "index_posts_on_provider_uid"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.string   "job_title"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.text     "linkedin_data"
    t.string   "linkedin_profile"
  end

  add_index "profiles", ["first_name"], :name => "index_profiles_on_first_name"
  add_index "profiles", ["last_name"], :name => "index_profiles_on_last_name"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "profiles_company_depts", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "company_dept_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "profiles_company_depts", ["company_dept_id"], :name => "index_profiles_company_depts_on_company_dept_id"
  add_index "profiles_company_depts", ["profile_id"], :name => "index_profiles_company_depts_on_profile_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "role"
    t.string   "password_digest"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "admin_invite_token"
    t.datetime "admin_invite_sent_at"
    t.boolean  "pending",                :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"

  create_table "users_companies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "star_rating", :default => 0
  end

  add_index "users_companies", ["company_id"], :name => "index_users_companies_on_company_id"
  add_index "users_companies", ["user_id"], :name => "index_users_companies_on_user_id"

  create_table "verticals", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
