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

ActiveRecord::Schema.define(:version => 20130509154131) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "website_url"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "banner"
    t.integer  "width"
    t.integer  "height"
    t.string   "subdomain"
    t.string   "content_instagram"
    t.string   "content_facebook"
    t.string   "content_tumblr"
    t.string   "content_twitter"
    t.string   "content_jobs_page"
    t.string   "short_description", :limit => 80
    t.string   "hq_city"
    t.string   "hq_state"
    t.string   "employee_count"
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

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.string   "job_title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "first_name"
    t.string   "last_name"
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
    t.integer  "company_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["company_id"], :name => "index_users_on_company_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"

  create_table "users_companies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users_companies", ["company_id"], :name => "index_users_companies_on_company_id"
  add_index "users_companies", ["user_id"], :name => "index_users_companies_on_user_id"

  create_table "verticals", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
