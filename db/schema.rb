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

ActiveRecord::Schema.define(version: 20120905133430) do

  create_table "arguments", force: true do |t|
    t.string   "content",                       null: false
    t.integer  "argtype",                       default: 3, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "title"
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id",                       null: false
    t.string   "provider",                      null: false
    t.string   "uid",                           null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end
  add_index "authentications", ["user_id"], name: "user_id"
  add_index "authentications", ["user_id", "uid"], name: "user_id_and_uid", unique: true

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",                default: 0
    t.string   "commentable_type",              default: ""
    t.string   "title",                         default: ""
    t.text     "body",                          default: ""
    t.string   "subject",                       default: ""
    t.integer  "user_id",                       default: 0,  null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "profiles", force: true do |t|
    t.integer  "user_id"#,                       null: false
    t.string   "name",                          default: ""
    t.text     "about",                         default: ""
    t.string   "picture",                       default: ""
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end
  add_index "profiles", ['user_id'], name: "profiles_by_user_id", unique: true

  create_table "roles", force: true do |t|
    t.string   "name",                          null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id",                        null: false
    t.integer "user_id",                        null: false
  end
  add_index "roles_users", ["user_id", "role_id"], name: "user_role", unique: true


  create_table "statementarguments", force: true do |t|
    t.integer "argument_id",                    null: false
    t.integer "statement_id",                   null: false
    t.boolean "pro",                            default: true, null: false
    t.integer "votes_count",                    default: 0
  end
  add_index "statementarguments", ["argument_id", "statement_id"], name: "arg_state_index"

  create_table "statements", force: true do |t|
    t.string   "title",                         null: false
    t.string   "content",                       null: false
    t.integer  "statetype",                     default: 6
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                         default: ""
    t.string   "encrypted_password",            default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "username"
    t.string   "unconfirmed_email"
  end
  add_index "users", ["email"], name: "index_users_on_email", where: "email IS NOT NULL", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "versions", force: true do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit",                     null: false
    t.text     "object"
    t.datetime "created_at"
  end
  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "votes", force: true do |t|
    t.integer  "statementargument_id",          null: false
    t.integer  "user_id",                       null: false
    t.integer  "vote_type"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end
  add_index "votes", ["statementargument_id", "user_id"], name: "index_votes_on_statementargument_id_and_user_id", unique: true

end
