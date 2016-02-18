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

ActiveRecord::Schema.define(version: 20160329060056) do

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
    t.integer  "sign_ups",     default: 0
  end

  add_index "access_tokens", ["access_token"], name: "index_access_tokens_on_access_token", using: :btree
  add_index "access_tokens", ["item_id", "item_type"], name: "index_access_tokens_on_item_id_and_item_type", using: :btree

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
    t.json     "audit_data"
    t.datetime "deleted_at"
  end

  add_index "activities", ["deleted_at"], name: "index_activities_on_deleted_at", using: :btree
  add_index "activities", ["forum_id", "owner_id", "owner_type"], name: "index_activities_on_forum_id_and_owner_id_and_owner_type", using: :btree
  add_index "activities", ["forum_id", "trackable_id", "trackable_type"], name: "forum_trackable", using: :btree
  add_index "activities", ["forum_id"], name: "index_activities_on_forum_id", using: :btree
  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.integer  "publisher_id"
    t.string   "title"
    t.text     "content"
    t.integer  "audience",     default: 0,    null: false
    t.integer  "sample_size",  default: 100,  null: false
    t.boolean  "dismissable",  default: true, null: false
    t.datetime "published_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "trashed_at"
  end

  add_index "announcements", ["published_at"], name: "index_announcements_on_published_at", using: :btree

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
    t.integer  "publisher_id"
    t.datetime "deleted_at"
  end

  add_index "arguments", ["deleted_at"], name: "index_arguments_on_deleted_at", using: :btree
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

  create_table "banners", force: :cascade do |t|
    t.string   "type"
    t.integer  "forum_id"
    t.integer  "publisher_id"
    t.string   "title"
    t.text     "content"
    t.integer  "cited_profile_id"
    t.string   "cited_avatar"
    t.string   "cited_name"
    t.string   "cited_function"
    t.integer  "audience",         default: 0,    null: false
    t.integer  "sample_size",      default: 100,  null: false
    t.boolean  "dismissable",      default: true, null: false
    t.datetime "published_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "banners", ["forum_id", "published_at"], name: "index_banners_on_forum_id_and_published_at", using: :btree
  add_index "banners", ["forum_id"], name: "index_banners_on_forum_id", using: :btree

  create_table "blog_posts", force: :cascade do |t|
    t.integer  "forum_id",                       null: false
    t.integer  "blog_postable_id"
    t.string   "blog_postable_type"
    t.integer  "creator_id",                     null: false
    t.integer  "publisher_id"
    t.integer  "state",              default: 0, null: false
    t.string   "title",                          null: false
    t.text     "content"
    t.integer  "comments_count",     default: 0, null: false
    t.datetime "published_at"
    t.datetime "trashed_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "blog_posts", ["forum_id", "published_at"], name: "index_blog_posts_on_forum_id_and_published_at", using: :btree
  add_index "blog_posts", ["forum_id", "trashed_at"], name: "index_blog_posts_on_forum_id_and_trashed_at", using: :btree
  add_index "blog_posts", ["id", "forum_id"], name: "index_blog_posts_on_id_and_forum_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",               default: 0
    t.string   "commentable_type", limit: 255, default: ""
    t.string   "title",            limit: 255, default: ""
    t.text     "body",                         default: ""
    t.string   "subject",          limit: 255, default: ""
    t.integer  "creator_id",                   default: 0
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_trashed",                   default: false
    t.integer  "publisher_id"
    t.datetime "deleted_at"
    t.integer  "forum_id"
  end

  add_index "comments", ["commentable_id", "commentable_type", "is_trashed"], name: "index_comments_on_id_and_type_and_trashed", using: :btree
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["creator_id"], name: "index_comments_on_profile_id", using: :btree
  add_index "comments", ["deleted_at"], name: "index_comments_on_deleted_at", using: :btree
  add_index "comments", ["profile_id"], name: "index_comments_on_profile_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["name"], name: "index_documents_on_name", using: :btree

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
    t.boolean  "send_email",      default: false
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree
  add_index "follows", ["follower_type", "follower_id", "followable_type", "followable_id"], name: "index_follower_followable", unique: true, using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "name"
    t.integer  "page_id"
    t.integer  "questions_count",                    default: 0,     null: false
    t.integer  "motions_count",                      default: 0,     null: false
    t.integer  "memberships_count",                  default: 0,     null: false
    t.string   "profile_photo"
    t.string   "cover_photo"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "slug"
    t.text     "bio",                                default: "",    null: false
    t.text     "featured_tags",                      default: "",    null: false
    t.integer  "visibility",                         default: 1
    t.string   "cover_photo_attribution",            default: ""
    t.boolean  "visible_with_a_link",                default: false
    t.boolean  "signup_with_token?",                 default: false
    t.text     "bio_long",                           default: ""
    t.boolean  "uses_alternative_names",             default: false, null: false
    t.string   "questions_title"
    t.string   "questions_title_singular"
    t.string   "motions_title"
    t.string   "motions_title_singular"
    t.string   "arguments_title"
    t.string   "arguments_title_singular"
    t.integer  "lock_version",                       default: 0
    t.integer  "place_id",                 limit: 8
    t.integer  "projects_count",                     default: 0,     null: false
  end

  add_index "forums", ["slug"], name: "index_forums_on_slug", unique: true, using: :btree
  add_index "forums", ["visibility"], name: "index_forums_on_visibility", using: :btree

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "group_memberships", ["group_id", "member_id"], name: "index_group_memberships_on_group_id_and_member_id", unique: true, using: :btree

  create_table "group_responses", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "group_id"
    t.integer  "creator_id"
    t.integer  "motion_id"
    t.text     "text",         default: ""
    t.integer  "publisher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "side",         default: 0
    t.datetime "deleted_at"
  end

  add_index "group_responses", ["deleted_at"], name: "index_group_responses_on_deleted_at", using: :btree
  add_index "group_responses", ["group_id", "forum_id"], name: "index_group_responses_on_group_id_and_forum_id", using: :btree
  add_index "group_responses", ["group_id", "motion_id"], name: "index_group_responses_on_group_id_and_motion_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "forum_id"
    t.string   "name",                     default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_singular"
    t.integer  "max_responses_per_member", default: 1
    t.string   "icon"
    t.integer  "visibility",               default: 0
    t.boolean  "deletable",                default: true
    t.text     "description"
  end

  add_index "groups", ["forum_id", "name"], name: "index_groups_on_forum_id_and_name", unique: true, using: :btree
  add_index "groups", ["forum_id"], name: "index_groups_on_forum_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "identities", ["uid", "provider"], name: "index_identities_on_uid_and_provider", using: :btree
  add_index "identities", ["uid"], name: "index_identities_on_uid", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "locales", force: :cascade do |t|
    t.string "code",           null: false
    t.string "name",           null: false
    t.string "alternate_name"
  end

  add_index "locales", ["code"], name: "index_locales_on_code", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "profile_id",             null: false
    t.integer "forum_id",               null: false
    t.integer "role",       default: 0, null: false
  end

  add_index "memberships", ["forum_id", "role"], name: "index_memberships_on_forum_id_and_role", using: :btree
  add_index "memberships", ["forum_id"], name: "index_memberships_on_forum_id", using: :btree
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
    t.integer  "publisher_id"
    t.datetime "deleted_at"
    t.integer  "question_id"
    t.integer  "place_id",                limit: 8
    t.integer  "project_id"
  end

  add_index "motions", ["deleted_at"], name: "index_motions_on_deleted_at", using: :btree
  add_index "motions", ["forum_id"], name: "index_motions_on_forum_id", using: :btree
  add_index "motions", ["id"], name: "index_motions_on_id", using: :btree
  add_index "motions", ["is_trashed"], name: "index_motions_on_is_trashed", using: :btree
  add_index "motions", ["tag_id"], name: "index_motions_on_tag_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "url"
    t.datetime "deleted_at"
  end

  add_index "notifications", ["activity_id"], name: "index_notifications_on_activity_id", using: :btree
  add_index "notifications", ["deleted_at"], name: "index_notifications_on_deleted_at", using: :btree
  add_index "notifications", ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

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

  add_index "page_memberships", ["page_id"], name: "index_page_memberships_on_page_id", using: :btree
  add_index "page_memberships", ["profile_id"], name: "index_page_memberships_on_profile_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "slug"
    t.integer  "visibility",    default: 1
    t.integer  "owner_id"
    t.datetime "last_accepted"
  end

  add_index "pages", ["owner_id"], name: "index_pages_on_owner_id", using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "phases", force: :cascade do |t|
    t.integer  "forum_id",     null: false
    t.integer  "project_id",   null: false
    t.integer  "creator_id",   null: false
    t.integer  "publisher_id"
    t.integer  "position"
    t.string   "name"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "phases", ["forum_id", "project_id"], name: "index_phases_on_forum_id_and_project_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "forum_id",                 null: false
    t.integer  "about_id",                 null: false
    t.string   "about_type",               null: false
    t.integer  "used_as",      default: 0
    t.integer  "creator_id"
    t.integer  "publisher_id"
    t.string   "image_uid"
    t.string   "title"
    t.text     "description"
    t.datetime "date_created"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "photos", ["about_id", "about_type"], name: "index_photos_on_about_id_and_about_type", using: :btree
  add_index "photos", ["forum_id"], name: "index_photos_on_forum_id", using: :btree

  create_table "placements", force: :cascade do |t|
    t.integer "forum_id"
    t.integer "place_id",       null: false
    t.integer "placeable_id",   null: false
    t.string  "placeable_type", null: false
    t.string  "title"
    t.text    "about"
    t.integer "creator_id",     null: false
    t.integer "publisher_id"
  end

  add_index "placements", ["forum_id"], name: "index_placements_on_forum_id", using: :btree

  create_table "places", id: :bigserial, force: :cascade do |t|
    t.string  "licence"
    t.string  "osm_type"
    t.integer "osm_id",         limit: 8
    t.text    "boundingbox",                                        default: [], array: true
    t.decimal "lat",                      precision: 64, scale: 12
    t.decimal "lon",                      precision: 64, scale: 12
    t.string  "display_name"
    t.string  "osm_class"
    t.string  "osm_importance"
    t.string  "icon"
    t.string  "osm_category"
    t.json    "address"
    t.json    "extratags"
    t.json    "namedetails"
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name",             limit: 255, default: ""
    t.text     "about",                        default: ""
    t.string   "picture",          limit: 255, default: ""
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "profile_photo",    limit: 255
    t.string   "cover_photo",      limit: 255
    t.string   "slug"
    t.boolean  "is_public",                    default: true
    t.boolean  "are_votes_public",             default: true
    t.string   "profileable_type"
    t.integer  "profileable_id"
  end

  add_index "profiles", ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable_type_and_profileable_id", unique: true, using: :btree
  add_index "profiles", ["slug"], name: "index_profiles_on_slug", unique: true, using: :btree

  create_table "profiles_roles", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles_roles", ["profile_id", "role_id"], name: "index_profiles_roles_on_profile_id_and_role_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "forum_id",                      null: false
    t.integer  "creator_id",                    null: false
    t.integer  "publisher_id"
    t.integer  "group_id"
    t.integer  "state",             default: 0, null: false
    t.string   "title",                         null: false
    t.text     "content"
    t.datetime "start_date"
    t.string   "email"
    t.datetime "end_date"
    t.datetime "achieved_end_date"
    t.integer  "questions_count",   default: 0, null: false
    t.integer  "motions_count",     default: 0, null: false
    t.integer  "phases_count",      default: 0, null: false
    t.datetime "published_at"
    t.datetime "trashed_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "projects", ["forum_id", "trashed_at"], name: "index_projects_on_forum_id_and_trashed_at", using: :btree
  add_index "projects", ["forum_id"], name: "index_projects_on_forum_id", using: :btree

  create_table "question_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "motion_id"
    t.integer  "votes_pro_count", default: 0
    t.integer  "votes_con_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.boolean  "migrated",        default: false, null: false
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
    t.datetime "expires_at"
    t.integer  "publisher_id"
    t.datetime "deleted_at"
    t.boolean  "uses_alternative_names",              default: false, null: false
    t.string   "motions_title_singular"
    t.string   "motions_title"
    t.integer  "place_id",                limit: 8
    t.integer  "project_id"
  end

  add_index "questions", ["deleted_at"], name: "index_questions_on_deleted_at", using: :btree
  add_index "questions", ["forum_id", "is_trashed"], name: "index_questions_on_forum_id_and_is_trashed", using: :btree
  add_index "questions", ["forum_id"], name: "index_questions_on_forum_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rules", force: :cascade do |t|
    t.string   "model_type"
    t.integer  "model_id"
    t.string   "action"
    t.string   "role"
    t.boolean  "permit"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "context_type",             null: false
    t.integer  "context_id",               null: false
    t.integer  "trickles",     default: 0, null: false
    t.string   "message"
  end

  add_index "rules", ["context_id", "context_type"], name: "index_rules_on_context_id_and_context_type", using: :btree
  add_index "rules", ["model_id", "model_type"], name: "index_rules_on_model_id_and_model_type", using: :btree

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

  create_table "shortnames", force: :cascade do |t|
    t.string   "shortname",  null: false
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shortnames", ["owner_id", "owner_type"], name: "index_shortnames_on_owner_id_and_owner_type", unique: true, using: :btree

  create_table "stepups", force: :cascade do |t|
    t.integer "forum_id",    null: false
    t.integer "record_id",   null: false
    t.string  "record_type", null: false
    t.integer "group_id"
    t.integer "user_id"
    t.integer "creator_id"
    t.string  "title"
    t.text    "description"
  end

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

  create_table "translations", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "locale_id"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translations", ["forum_id", "key", "locale_id"], name: "index_translations_on_forum_id_and_key_and_locale_id", unique: true, using: :btree
  add_index "translations", ["key", "locale_id"], name: "index_translations_on_key_and_locale_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                   limit: 255, default: ""
    t.string   "encrypted_password",      limit: 255, default: ""
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "unconfirmed_email",       limit: 255
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                   default: 0
    t.boolean  "finished_intro",                      default: false
    t.integer  "follows_email",                       default: 0,     null: false
    t.boolean  "follows_mobile",                      default: true,  null: false
    t.integer  "memberships_email",                   default: 1,     null: false
    t.boolean  "memberships_mobile",                  default: true,  null: false
    t.integer  "created_email",                       default: 1,     null: false
    t.boolean  "created_mobile",                      default: true,  null: false
    t.text     "r"
    t.text     "access_tokens"
    t.text     "omni_info"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text     "active_sessions",                     default: [],                 array: true
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "birthday"
    t.datetime "last_accepted"
    t.boolean  "has_analytics",                       default: true
    t.integer  "gender"
    t.integer  "hometown"
    t.string   "time_zone",                           default: "UTC"
    t.string   "language",                            default: "nl"
    t.string   "country",                             default: "NL"
    t.integer  "failed_attempts",                     default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "notifications_viewed_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "voteable_id"
    t.string   "voteable_type", limit: 255
    t.integer  "voter_id"
    t.string   "voter_type",    limit: 255
    t.integer  "for",                       default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.datetime "deleted_at"
  end

  add_index "votes", ["deleted_at"], name: "index_votes_on_deleted_at", using: :btree
  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], name: "index_votes_on_voter_and_voteable_and_trashed", using: :btree
  add_index "votes", ["voteable_id", "voteable_type", "voter_id", "voter_type"], name: "no_duplicate_votes", unique: true, using: :btree
  add_index "votes", ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

  add_foreign_key "access_tokens", "profiles"
  add_foreign_key "arguments", "users", column: "publisher_id"
  add_foreign_key "banners", "forums", on_delete: :cascade
  add_foreign_key "blog_posts", "forums"
  add_foreign_key "blog_posts", "profiles", column: "creator_id"
  add_foreign_key "blog_posts", "users", column: "publisher_id"
  add_foreign_key "comments", "forums"
  add_foreign_key "comments", "users", column: "publisher_id"
  add_foreign_key "forums", "places"
  add_foreign_key "group_responses", "users", column: "publisher_id"
  add_foreign_key "identities", "users"
  add_foreign_key "motions", "places"
  add_foreign_key "motions", "projects"
  add_foreign_key "motions", "users", column: "publisher_id"
  add_foreign_key "notifications", "activities"
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "phases", "forums"
  add_foreign_key "phases", "profiles", column: "creator_id"
  add_foreign_key "phases", "projects"
  add_foreign_key "phases", "users", column: "publisher_id"
  add_foreign_key "photos", "forums"
  add_foreign_key "photos", "profiles", column: "creator_id"
  add_foreign_key "photos", "users", column: "publisher_id"
  add_foreign_key "placements", "forums"
  add_foreign_key "placements", "places"
  add_foreign_key "placements", "profiles", column: "creator_id"
  add_foreign_key "placements", "users", column: "publisher_id"
  add_foreign_key "projects", "forums"
  add_foreign_key "projects", "groups"
  add_foreign_key "projects", "profiles", column: "creator_id"
  add_foreign_key "projects", "users", column: "publisher_id"
  add_foreign_key "question_answers", "profiles", column: "creator_id"
  add_foreign_key "questions", "places"
  add_foreign_key "questions", "projects"
  add_foreign_key "questions", "users", column: "publisher_id"
  add_foreign_key "stepups", "forums"
  add_foreign_key "stepups", "groups"
  add_foreign_key "stepups", "profiles", column: "creator_id"
  add_foreign_key "stepups", "users"
end
