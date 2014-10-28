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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141028104930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arguments", force: true do |t|
    t.text     "content",                             null: false
    t.integer  "statement_id",                        null: false
    t.boolean  "pro",                 default: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "title"
    t.boolean  "is_trashed",          default: false
    t.integer  "votes_pro_count",     default: 0,     null: false
    t.integer  "comments_count",      default: 0,     null: false
    t.integer  "votes_abstain_count", default: 0,     null: false
    t.integer  "creator_id"
  end

  add_index "arguments", ["id"], name: "index_arguments_on_id", using: :btree
  add_index "arguments", ["statement_id", "id", "pro"], name: "index_arguments_on_statement_id_and_id_and_pro", using: :btree
  add_index "arguments", ["statement_id", "id"], name: "index_arguments_on_statement_id_and_id", using: :btree
  add_index "arguments", ["statement_id", "is_trashed"], name: "index_arguments_on_statement_id_and_is_trashed", using: :btree
  add_index "arguments", ["statement_id"], name: "statement_id", using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentications", ["user_id", "uid"], name: "user_id_and_uid", unique: true, using: :btree
  add_index "authentications", ["user_id"], name: "user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type", default: ""
    t.string   "title",            default: ""
    t.text     "body",             default: ""
    t.string   "subject",          default: ""
    t.integer  "profile_id",       default: 0,     null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "is_trashed",       default: false
  end

  add_index "comments", ["commentable_id", "commentable_type", "is_trashed"], name: "index_comments_on_id_and_type_and_trashed", using: :btree
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["profile_id"], name: "index_comments_on_profile_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "follows", force: true do |t|
    t.integer  "user_id"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "group_memberships", force: true do |t|
    t.integer "profile_id"
    t.integer "group_id"
    t.integer "role",       default: 0, null: false
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.text     "description"
    t.string   "slogan"
    t.string   "key_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "web_url"
    t.integer  "memberships_count", default: 0, null: false
    t.integer  "statements_count",  default: 0, null: false
    t.integer  "scope",             default: 0, null: false
    t.integer  "application_form",  default: 0, null: false
    t.integer  "public_form",       default: 0, null: false
    t.string   "profile_photo"
    t.string   "cover_photo"
  end

  add_index "groups", ["name"], name: "groups_name_idx", using: :btree
  add_index "groups", ["web_url"], name: "groups_web_url_idx", using: :btree

  create_table "memberships", force: true do |t|
    t.integer "profile_id"
    t.integer "organisation_id"
    t.integer "role",            default: 0, null: false
  end

  add_index "memberships", ["profile_id", "organisation_id"], name: "index_memberships_on_profile_id_and_organisation_id", unique: true, using: :btree

  create_table "opinions", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "is_trashed",          default: false
    t.boolean  "pro",                 default: false
    t.integer  "statement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_pro_count",     default: 0,     null: false
    t.integer  "comments_count",      default: 0,     null: false
    t.integer  "votes_abstain_count", default: 0,     null: false
    t.integer  "creator_id"
  end

  add_index "opinions", ["id"], name: "index_opinions_on_id", using: :btree
  add_index "opinions", ["statement_id", "id", "pro"], name: "index_opinions_on_statement_id_and_id_and_pro", using: :btree
  add_index "opinions", ["statement_id", "id"], name: "index_opinions_on_statement_id_and_id", using: :btree
  add_index "opinions", ["statement_id", "is_trashed"], name: "index_opinions_on_statement_id_and_is_trashed", using: :btree

  create_table "organisations", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.text     "description"
    t.string   "slogan"
    t.string   "key_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "web_url"
    t.integer  "memberships_count", default: 0, null: false
    t.integer  "statements_count",  default: 0, null: false
    t.integer  "scope",             default: 0, null: false
    t.integer  "application_form",  default: 0, null: false
    t.integer  "public_form",       default: 0, null: false
    t.string   "profile_photo"
    t.string   "cover_photo"
  end

  add_index "organisations", ["id"], name: "index_organisations_on_id", using: :btree
  add_index "organisations", ["name"], name: "index_organisations_on_name", using: :btree
  add_index "organisations", ["web_url"], name: "index_organisations_on_web_url", using: :btree

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.string   "name",          default: ""
    t.text     "about",         default: ""
    t.string   "picture",       default: ""
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "profile_photo"
    t.string   "cover_photo"
  end

  add_index "profiles", ["user_id"], name: "profiles_by_user_id", unique: true, using: :btree

  create_table "profiles_roles", id: false, force: true do |t|
    t.integer "profile_id"
    t.integer "role_id"
  end

  add_index "profiles_roles", ["profile_id", "role_id"], name: "index_profiles_roles_on_profile_id_and_role_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "statementarguments", force: true do |t|
    t.integer "argument_id",                 null: false
    t.integer "statement_id",                null: false
    t.boolean "pro",          default: true, null: false
    t.integer "votes_count",  default: 0
  end

  add_index "statementarguments", ["argument_id", "statement_id"], name: "arg_state_index", using: :btree

  create_table "statements", force: true do |t|
    t.string   "title",                               null: false
    t.text     "content",                             null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "pro_count",           default: 0
    t.integer  "con_count",           default: 0
    t.integer  "tag_id"
    t.boolean  "is_trashed",          default: false
    t.integer  "votes_pro_count",     default: 0,     null: false
    t.integer  "votes_con_count",     default: 0,     null: false
    t.integer  "votes_neutral_count", default: 0,     null: false
    t.integer  "argument_pro_count",  default: 0,     null: false
    t.integer  "argument_con_count",  default: 0,     null: false
    t.integer  "opinion_pro_count",   default: 0,     null: false
    t.integer  "opinion_con_count",   default: 0,     null: false
    t.integer  "votes_abstain_count", default: 0,     null: false
    t.integer  "organisation_id"
    t.integer  "creator_id"
  end

  add_index "statements", ["id"], name: "index_statements_on_id", using: :btree
  add_index "statements", ["is_trashed"], name: "index_statements_on_is_trashed", using: :btree
  add_index "statements", ["organisation_id"], name: "index_statements_on_organisation_id", using: :btree
  add_index "statements", ["tag_id"], name: "index_statements_on_tag_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.integer  "for",           default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], name: "index_votes_on_voter_and_voteable_and_trashed", using: :btree
  add_index "votes", ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

end
