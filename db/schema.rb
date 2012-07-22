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

ActiveRecord::Schema.define(:version => 20120722123521) do

  create_table "arguments", :force => true do |t|
    t.string   "content",                   :null => false
    t.integer  "argtype",    :default => 3, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "title"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",                       :null => false
    t.text     "value"
    t.integer  "target_id"
    t.string   "target_type", :limit => 30
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "settings", ["target_type", "target_id", "var"], :name => "index_settings_on_target_type_and_target_id_and_var", :unique => true

  create_table "statementarguments", :force => true do |t|
    t.integer "argument_id",                    :null => false
    t.integer "statement_id",                   :null => false
    t.boolean "pro",          :default => true, :null => false
    t.integer "votes_count",  :default => 0
  end

  create_table "statements", :force => true do |t|
    t.string   "title",                     :null => false
    t.string   "content",                   :null => false
    t.integer  "statetype",  :default => 6
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                          :null => false
    t.string   "name"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "clearance",       :default => 4
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "votes", :force => true do |t|
    t.integer  "statementargument_id", :null => false
    t.integer  "user_id",              :null => false
    t.integer  "vote_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "votes", ["statementargument_id", "user_id"], :name => "index_votes_on_statementargument_id_and_user_id", :unique => true

end
