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

ActiveRecord::Schema.define(version: 20150209210021) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "access_token",             null: false
    t.integer  "profile_id",               null: false
    t.integer  "usages",       default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "forum_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["forum_id", "owner_id", "owner_type"], name: "index_activities_on_forum_id_and_owner_id_and_owner_type", using: :btree
  add_index "activities", ["forum_id", "trackable_id", "trackable_type"], name: "forum_trackable", using: :btree
  add_index "activities", ["forum_id"], name: "index_activities_on_forum_id", using: :btree
  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "arguments", force: :cascade do |t|
    t.text     "content",                                         null: false
    t.integer  "motion_id",                                       null: false
    t.boolean  "pro",                             default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "title",               limit: 255
    t.boolean  "is_trashed",                      default: false
    t.integer  "votes_pro_count",                 default: 0,     null: false
    t.integer  "comments_count",                  default: 0,     null: false
    t.integer  "votes_abstain_count",             default: 0,     null: false
    t.integer  "creator_id"
    t.integer  "votes_con_count",                 default: 0,     null: false
    t.integer  "forum_id"
  end

  add_index "arguments", ["id"], name: "index_arguments_on_id", using: :btree
  add_index "arguments", ["motion_id", "id", "pro"], name: "index_arguments_on_motion_id_and_id_and_pro", using: :btree
  add_index "arguments", ["motion_id", "id"], name: "index_arguments_on_motion_id_and_id", using: :btree
  add_index "arguments", ["motion_id", "is_trashed"], name: "index_arguments_on_motion_id_and_is_trashed", using: :btree
  add_index "arguments", ["motion_id"], name: "statement_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "provider",   limit: 255, null: false
    t.string   "uid",        limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "authentications", ["user_id", "uid"], name: "user_id_and_uid", unique: true, using: :btree
  add_index "authentications", ["user_id"], name: "user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",               default: 0
    t.string   "commentable_type", limit: 255, default: ""
    t.string   "title",            limit: 255, default: ""
    t.text     "body",                         default: ""
    t.string   "subject",          limit: 255, default: ""
    t.integer  "profile_id",                   default: 0,     null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_trashed",                   default: false
  end

  add_index "comments", ["commentable_id", "commentable_type", "is_trashed"], name: "index_comments_on_id_and_type_and_trashed", using: :btree
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["profile_id"], name: "index_comments_on_profile_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edits", force: :cascade do |t|
    t.integer  "by_id"
    t.string   "by_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "action"
    t.text     "custom"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edits", ["by_type", "by_id"], name: "index_edits_on_by_type_and_by_id", using: :btree
  add_index "edits", ["item_type", "item_id"], name: "index_edits_on_item_type_and_item_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "name"
    t.integer  "page_id"
    t.integer  "questions_count",         default: 0,     null: false
    t.integer  "motions_count",           default: 0,     null: false
    t.integer  "memberships_count",       default: 0,     null: false
    t.string   "profile_photo"
    t.string   "cover_photo"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "slug"
    t.string   "web_url",                 default: "",    null: false
    t.text     "bio",                     default: "",    null: false
    t.text     "featured_tags",           default: "",    null: false
    t.integer  "visibility",              default: 1
    t.string   "cover_photo_attribution", default: ""
    t.boolean  "visible_with_a_link",     default: false
    t.boolean  "signup_with_token?",      default: false
    t.text     "bio_long",                default: ""
  end

  add_index "forums", ["slug"], name: "index_forums_on_slug", unique: true, using: :btree
  add_index "forums", ["web_url"], name: "index_forums_on_web_url", unique: true, using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "profile_id",             null: false
    t.integer "forum_id",               null: false
    t.integer "role",       default: 0, null: false
  end

  add_index "memberships", ["profile_id", "forum_id"], name: "index_memberships_on_profile_id_and_forum_id", unique: true, using: :btree

  create_table "motions", force: :cascade do |t|
    t.string   "title",                   limit: 255,                 null: false
    t.text     "content",                                             null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "pro_count",                           default: 0
    t.integer  "con_count",                           default: 0
    t.integer  "tag_id"
    t.boolean  "is_trashed",                          default: false
    t.integer  "votes_pro_count",                     default: 0,     null: false
    t.integer  "votes_con_count",                     default: 0,     null: false
    t.integer  "votes_neutral_count",                 default: 0,     null: false
    t.integer  "argument_pro_count",                  default: 0,     null: false
    t.integer  "argument_con_count",                  default: 0,     null: false
    t.integer  "opinion_pro_count",                   default: 0,     null: false
    t.integer  "opinion_con_count",                   default: 0,     null: false
    t.integer  "votes_abstain_count",                 default: 0,     null: false
    t.integer  "forum_id"
    t.integer  "creator_id"
    t.string   "cover_photo",                         default: ""
    t.string   "cover_photo_attribution",             default: ""
  end

  add_index "motions", ["forum_id"], name: "index_motions_on_forum_id", using: :btree
  add_index "motions", ["id"], name: "index_motions_on_id", using: :btree
  add_index "motions", ["is_trashed"], name: "index_motions_on_is_trashed", using: :btree
  add_index "motions", ["tag_id"], name: "index_motions_on_tag_id", using: :btree

  create_table "opinions", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "content"
    t.boolean  "is_trashed",                      default: false
    t.boolean  "pro",                             default: false
    t.integer  "motion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_pro_count",                 default: 0,     null: false
    t.integer  "comments_count",                  default: 0,     null: false
    t.integer  "votes_abstain_count",             default: 0,     null: false
    t.integer  "creator_id"
    t.integer  "forum_id"
  end

  add_index "opinions", ["id"], name: "index_opinions_on_id", using: :btree
  add_index "opinions", ["motion_id", "id", "pro"], name: "index_opinions_on_motion_id_and_id_and_pro", using: :btree
  add_index "opinions", ["motion_id", "id"], name: "index_opinions_on_motion_id_and_id", using: :btree
  add_index "opinions", ["motion_id", "is_trashed"], name: "index_opinions_on_motion_id_and_is_trashed", using: :btree

  create_table "page_memberships", force: :cascade do |t|
    t.integer "profile_id",             null: false
    t.integer "page_id",                null: false
    t.integer "role",       default: 0, null: false
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "slug"
    t.string   "web_url",    default: "", null: false
    t.integer  "profile_id"
    t.integer  "visibility", default: 1
    t.integer  "owner_id"
  end

  add_index "pages", ["profile_id"], name: "index_pages_on_profile_id", unique: true, using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree
  add_index "pages", ["web_url"], name: "index_pages_on_web_url", unique: true, using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name",          limit: 255, default: ""
    t.text     "about",                     default: ""
    t.string   "picture",       limit: 255, default: ""
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "profile_photo", limit: 255
    t.string   "cover_photo",   limit: 255
    t.string   "slug"
  end

  add_index "profiles", ["slug"], name: "index_profiles_on_slug", unique: true, using: :btree

  create_table "profiles_roles", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles_roles", ["profile_id", "role_id"], name: "index_profiles_roles_on_profile_id_and_role_id", using: :btree

  create_table "question_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "motion_id"
    t.integer  "votes_pro_count", default: 0
    t.integer  "votes_con_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_answers", ["question_id", "motion_id"], name: "index_question_answers_on_question_id_and_motion_id", unique: true, using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "title",                   limit: 255, default: ""
    t.text     "content",                             default: ""
    t.integer  "forum_id"
    t.integer  "creator_id"
    t.boolean  "is_trashed",                          default: false
    t.integer  "motions_count",                       default: 0
    t.integer  "votes_pro_count",                     default: 0
    t.integer  "votes_con_count",                     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_photo",                         default: ""
    t.string   "cover_photo_attribution",             default: ""
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.text   "value"
  end

  add_index "settings", ["key"], name: "index_settings_on_key", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.integer  "forum_id"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: ""
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "username",               limit: 255
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "profile_id"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                  default: 0
    t.boolean  "finished_intro",                     default: false
    t.integer  "follows_email",                      default: 1,     null: false
    t.boolean  "follows_mobile",                     default: true,  null: false
    t.integer  "memberships_email",                  default: 1,     null: false
    t.boolean  "memberships_mobile",                 default: true,  null: false
    t.integer  "created_email",                      default: 1,     null: false
    t.boolean  "created_mobile",                     default: true,  null: false
    t.text     "r"
    t.text     "access_tokens"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["profile_id"], name: "index_users_on_profile_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "voteable_id"
    t.string   "voteable_type", limit: 255
    t.integer  "voter_id"
    t.string   "voter_type",    limit: 255
    t.integer  "for",                       default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
  end

  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], name: "index_votes_on_voter_and_voteable_and_trashed", using: :btree
  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], name: "no_duplicate_votes", unique: true, using: :btree
  add_index "votes", ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

  add_foreign_key "access_tokens", "profiles", name: "access_tokens_profile_id_fk"
end
