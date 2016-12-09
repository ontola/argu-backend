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

ActiveRecord::Schema.define(version: 20161209085751) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "ltree"
  enable_extension "hstore"

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "access_token",             null: false
    t.integer  "profile_id",               null: false
    t.integer  "usages",       default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "sign_ups",     default: 0
    t.index ["access_token"], name: "index_access_tokens_on_access_token", using: :btree
    t.index ["item_id", "item_type"], name: "index_access_tokens_on_item_id_and_item_type", using: :btree
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "forum_id"
    t.integer  "owner_id"
    t.string   "owner_type",     default: "Profile"
    t.ltree    "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "audit_data"
    t.boolean  "is_published",   default: false,     null: false
    t.index ["forum_id", "owner_id", "owner_type"], name: "index_activities_on_forum_id_and_owner_id_and_owner_type", using: :btree
    t.index ["forum_id", "trackable_id", "trackable_type"], name: "forum_trackable", using: :btree
    t.index ["forum_id"], name: "index_activities_on_forum_id", using: :btree
    t.index ["key"], name: "index_activities_on_key", using: :gist
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

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
    t.datetime "ends_at"
    t.index ["published_at"], name: "index_announcements_on_published_at", using: :btree
  end

  create_table "arguments", force: :cascade do |t|
    t.text     "content"
    t.integer  "motion_id",                                       null: false
    t.boolean  "pro",                             default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "title",               limit: 255
    t.boolean  "is_trashed",                      default: false
    t.integer  "votes_pro_count",                 default: 0,     null: false
    t.integer  "comments_count",                  default: 0,     null: false
    t.integer  "votes_abstain_count",             default: 0,     null: false
    t.integer  "creator_id",                                      null: false
    t.integer  "votes_con_count",                 default: 0,     null: false
    t.integer  "forum_id"
    t.integer  "publisher_id",                                    null: false
    t.index ["id"], name: "index_arguments_on_id", using: :btree
    t.index ["motion_id", "id", "pro"], name: "index_arguments_on_motion_id_and_id_and_pro", using: :btree
    t.index ["motion_id", "id"], name: "index_arguments_on_motion_id_and_id", using: :btree
    t.index ["motion_id", "is_trashed"], name: "index_arguments_on_motion_id_and_is_trashed", using: :btree
    t.index ["motion_id"], name: "statement_id", using: :btree
  end

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "provider",   limit: 255, null: false
    t.string   "uid",        limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id", "uid"], name: "user_id_and_uid", unique: true, using: :btree
    t.index ["user_id"], name: "user_id", using: :btree
  end

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
    t.datetime "trashed_at"
    t.datetime "ends_at"
    t.index ["forum_id", "published_at"], name: "index_banners_on_forum_id_and_published_at", using: :btree
    t.index ["forum_id"], name: "index_banners_on_forum_id", using: :btree
  end

  create_table "blog_posts", force: :cascade do |t|
    t.integer  "forum_id",                           null: false
    t.integer  "blog_postable_id"
    t.string   "blog_postable_type"
    t.integer  "creator_id",                         null: false
    t.integer  "publisher_id",                       null: false
    t.integer  "state",              default: 0,     null: false
    t.string   "title",                              null: false
    t.text     "content"
    t.integer  "comments_count",     default: 0,     null: false
    t.datetime "trashed_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "is_published",       default: false, null: false
    t.index ["forum_id", "is_published"], name: "index_blog_posts_on_forum_id_and_is_published", using: :btree
    t.index ["forum_id", "trashed_at"], name: "index_blog_posts_on_forum_id_and_trashed_at", using: :btree
    t.index ["id", "forum_id"], name: "index_blog_posts_on_id_and_forum_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",               default: 0
    t.string   "commentable_type", limit: 255, default: ""
    t.string   "title",            limit: 255, default: ""
    t.text     "body",                         default: ""
    t.string   "subject",          limit: 255, default: ""
    t.integer  "creator_id",                   default: 0,     null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_trashed",                   default: false
    t.integer  "publisher_id",                                 null: false
    t.integer  "forum_id"
    t.index ["commentable_id", "commentable_type", "is_trashed"], name: "index_comments_on_id_and_type_and_trashed", using: :btree
    t.index ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
    t.index ["creator_id"], name: "index_comments_on_creator_id", using: :btree
  end

  create_table "decisions", force: :cascade do |t|
    t.integer  "forum_id",                           null: false
    t.integer  "decisionable_id",                    null: false
    t.integer  "forwarded_group_id"
    t.integer  "forwarded_user_id"
    t.integer  "publisher_id",                       null: false
    t.integer  "creator_id",                         null: false
    t.integer  "step",               default: 0,     null: false
    t.text     "content",            default: "",    null: false
    t.integer  "state",              default: 0,     null: false
    t.boolean  "is_published",       default: false, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_documents_on_name", using: :btree
  end

  create_table "edges", force: :cascade do |t|
    t.integer  "user_id",                          null: false
    t.integer  "parent_id"
    t.integer  "owner_id",                         null: false
    t.string   "owner_type",                       null: false
    t.ltree    "path"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "pinned_at"
    t.datetime "last_activity_at"
    t.datetime "trashed_at"
    t.boolean  "is_published",     default: false
    t.hstore   "children_counts",  default: {}
    t.integer  "follows_count",    default: 0,     null: false
    t.index ["owner_type", "owner_id"], name: "index_edges_on_owner_type_and_owner_id", unique: true, using: :btree
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
    t.index ["by_type", "by_id"], name: "index_edits_on_by_type_and_by_id", using: :btree
    t.index ["item_type", "item_id"], name: "index_edits_on_item_type_and_item_id", using: :btree
  end

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "edge_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "edge_id"], name: "index_favorites_on_user_id_and_edge_id", unique: true, using: :btree
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id",                    null: false
    t.string   "followable_type", default: "Edge", null: false
    t.integer  "follower_id",                      null: false
    t.string   "follower_type",   default: "User", null: false
    t.boolean  "blocked",         default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_email",      default: false
    t.integer  "follow_type",     default: 30,     null: false
    t.index ["followable_id", "followable_type"], name: "fk_followables", using: :btree
    t.index ["follower_id", "follower_type"], name: "fk_follows", using: :btree
    t.index ["follower_type", "follower_id", "followable_type", "followable_id"], name: "index_follower_followable", unique: true, using: :btree
  end

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
    t.text     "bio",                     default: "",    null: false
    t.text     "featured_tags",           default: "",    null: false
    t.integer  "visibility",              default: 3
    t.string   "cover_photo_attribution", default: ""
    t.boolean  "visible_with_a_link",     default: false
    t.boolean  "signup_with_token?",      default: false
    t.text     "bio_long",                default: ""
    t.integer  "lock_version",            default: 0
    t.bigint   "place_id"
    t.integer  "projects_count",          default: 0,     null: false
    t.integer  "max_shortname_count",     default: 0,     null: false
    t.index ["slug"], name: "index_forums_on_slug", unique: true, using: :btree
    t.index ["visibility"], name: "index_forums_on_visibility", using: :btree
  end

  create_table "grants", force: :cascade do |t|
    t.integer  "group_id",               null: false
    t.integer  "edge_id",                null: false
    t.integer  "role",       default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["group_id", "edge_id", "role"], name: "index_grants_on_group_id_and_edge_id_and_role", unique: true, using: :btree
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "group_id",    null: false
    t.integer  "member_id",   null: false
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.index ["group_id", "member_id"], name: "index_group_memberships_on_group_id_and_member_id", unique: true, using: :btree
  end

  create_table "group_responses", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "group_id"
    t.integer  "creator_id",                null: false
    t.integer  "motion_id"
    t.text     "text",         default: ""
    t.integer  "publisher_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "side",         default: 0
    t.index ["group_id", "forum_id"], name: "index_group_responses_on_group_id_and_forum_id", using: :btree
    t.index ["group_id", "motion_id"], name: "index_group_responses_on_group_id_and_motion_id", using: :btree
  end

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
    t.integer  "page_id",                                 null: false
    t.index ["forum_id", "name"], name: "index_groups_on_forum_id_and_name", unique: true, using: :btree
    t.index ["forum_id"], name: "index_groups_on_forum_id", using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_secret"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", using: :btree
    t.index ["uid"], name: "index_identities_on_uid", using: :btree
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "profile_id",             null: false
    t.integer "forum_id",               null: false
    t.integer "role",       default: 0, null: false
    t.index ["forum_id", "role"], name: "index_memberships_on_forum_id_and_role", using: :btree
    t.index ["forum_id"], name: "index_memberships_on_forum_id", using: :btree
    t.index ["profile_id", "forum_id"], name: "index_memberships_on_profile_id_and_forum_id", unique: true, using: :btree
  end

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
    t.integer  "votes_abstain_count",                 default: 0,     null: false
    t.integer  "forum_id"
    t.integer  "creator_id",                                          null: false
    t.string   "cover_photo",                         default: ""
    t.string   "cover_photo_attribution",             default: ""
    t.integer  "publisher_id",                                        null: false
    t.integer  "question_id"
    t.bigint   "place_id"
    t.integer  "project_id"
    t.index ["forum_id"], name: "index_motions_on_forum_id", using: :btree
    t.index ["id"], name: "index_motions_on_id", using: :btree
    t.index ["is_trashed"], name: "index_motions_on_is_trashed", using: :btree
    t.index ["tag_id"], name: "index_motions_on_tag_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "url"
    t.integer  "notification_type", null: false
    t.index ["activity_id"], name: "index_notifications_on_activity_id", using: :btree
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
    t.string   "resource_owner_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

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
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "page_memberships", force: :cascade do |t|
    t.integer "profile_id",             null: false
    t.integer "page_id",                null: false
    t.integer "role",       default: 0, null: false
    t.index ["page_id"], name: "index_page_memberships_on_page_id", using: :btree
    t.index ["profile_id"], name: "index_page_memberships_on_profile_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "slug"
    t.integer  "visibility",    default: 1
    t.integer  "owner_id"
    t.datetime "last_accepted"
    t.index ["owner_id"], name: "index_pages_on_owner_id", using: :btree
    t.index ["slug"], name: "index_pages_on_slug", unique: true, using: :btree
  end

  create_table "phases", force: :cascade do |t|
    t.integer  "forum_id",     null: false
    t.integer  "project_id",   null: false
    t.integer  "creator_id",   null: false
    t.integer  "publisher_id", null: false
    t.integer  "position"
    t.string   "name"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["forum_id", "project_id"], name: "index_phases_on_forum_id_and_project_id", using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "about_id",                 null: false
    t.string   "about_type",               null: false
    t.integer  "used_as",      default: 0, null: false
    t.integer  "creator_id",               null: false
    t.integer  "publisher_id",             null: false
    t.string   "image_uid"
    t.string   "title"
    t.text     "description"
    t.datetime "date_created"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["about_id", "about_type"], name: "index_photos_on_about_id_and_about_type", using: :btree
    t.index ["forum_id"], name: "index_photos_on_forum_id", using: :btree
  end

  create_table "placements", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "place_id",       null: false
    t.integer  "placeable_id",   null: false
    t.string   "placeable_type", null: false
    t.string   "title"
    t.text     "about"
    t.integer  "creator_id",     null: false
    t.integer  "publisher_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["forum_id"], name: "index_placements_on_forum_id", using: :btree
    t.index ["placeable_id"], name: "index_placements_on_placeable_id", unique: true, where: "(((title)::text = 'home'::text) AND ((placeable_type)::text = 'User'::text))", using: :btree
  end

  create_table "places", id: :bigserial, force: :cascade do |t|
    t.string  "licence"
    t.string  "osm_type"
    t.bigint  "osm_id"
    t.text    "boundingbox",                              default: [], array: true
    t.decimal "lat",            precision: 64, scale: 12
    t.decimal "lon",            precision: 64, scale: 12
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
    t.index ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable_type_and_profileable_id", unique: true, using: :btree
    t.index ["slug"], name: "index_profiles_on_slug", unique: true, using: :btree
  end

  create_table "profiles_roles", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["profile_id", "role_id"], name: "index_profiles_roles_on_profile_id_and_role_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "forum_id",                                null: false
    t.integer  "creator_id",                              null: false
    t.integer  "publisher_id",                            null: false
    t.integer  "group_id"
    t.integer  "state",                   default: 0,     null: false
    t.string   "title",                                   null: false
    t.text     "content"
    t.datetime "start_date"
    t.string   "email"
    t.datetime "end_date"
    t.datetime "achieved_end_date"
    t.integer  "questions_count",         default: 0,     null: false
    t.integer  "motions_count",           default: 0,     null: false
    t.integer  "phases_count",            default: 0,     null: false
    t.datetime "trashed_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "cover_photo",             default: ""
    t.string   "cover_photo_attribution", default: ""
    t.boolean  "is_published",            default: false, null: false
    t.integer  "blog_posts_count",        default: 0,     null: false
    t.index ["forum_id", "is_published"], name: "index_projects_on_forum_id_and_is_published", using: :btree
    t.index ["forum_id", "trashed_at"], name: "index_projects_on_forum_id_and_trashed_at", using: :btree
    t.index ["forum_id"], name: "index_projects_on_forum_id", using: :btree
  end

  create_table "publications", force: :cascade do |t|
    t.string   "job_id"
    t.datetime "published_at"
    t.integer  "publishable_id"
    t.string   "publishable_type", default: "Edge"
    t.string   "channel"
    t.integer  "creator_id",                        null: false
    t.integer  "publisher_id"
  end

  create_table "question_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "motion_id"
    t.integer  "votes_pro_count", default: 0
    t.integer  "votes_con_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.boolean  "migrated",        default: false, null: false
    t.index ["question_id", "motion_id"], name: "index_question_answers_on_question_id_and_motion_id", unique: true, using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.string   "title",                   limit: 255, default: ""
    t.text     "content",                             default: ""
    t.integer  "forum_id"
    t.integer  "creator_id",                                          null: false
    t.boolean  "is_trashed",                          default: false
    t.integer  "motions_count",                       default: 0
    t.integer  "votes_pro_count",                     default: 0
    t.integer  "votes_con_count",                     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_photo",                         default: ""
    t.string   "cover_photo_attribution",             default: ""
    t.datetime "expires_at"
    t.integer  "publisher_id",                                        null: false
    t.bigint   "place_id"
    t.integer  "project_id"
    t.index ["forum_id", "is_trashed"], name: "index_questions_on_forum_id_and_is_trashed", using: :btree
    t.index ["forum_id"], name: "index_questions_on_forum_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "rules", force: :cascade do |t|
    t.string   "model_type"
    t.integer  "model_id"
    t.string   "action"
    t.string   "role"
    t.boolean  "permit"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "context_type"
    t.integer  "context_id"
    t.integer  "trickles",     default: 0, null: false
    t.string   "message"
    t.integer  "branch_id",                null: false
    t.index ["branch_id"], name: "index_rules_on_branch_id", using: :btree
    t.index ["context_id", "context_type"], name: "index_rules_on_context_id_and_context_type", using: :btree
    t.index ["model_id", "model_type"], name: "index_rules_on_model_id_and_model_type", using: :btree
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.text   "value"
    t.index ["key"], name: "index_settings_on_key", unique: true, using: :btree
  end

  create_table "shortnames", force: :cascade do |t|
    t.string   "shortname",  null: false
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.index "lower((shortname)::text)", name: "index_shortnames_on_shortname", unique: true, using: :btree
    t.index ["owner_id", "owner_type"], name: "index_shortnames_on_owner_id_and_owner_type", unique: true, using: :btree
  end

  create_table "stepups", force: :cascade do |t|
    t.integer "forum_id",    null: false
    t.integer "record_id",   null: false
    t.string  "record_type", null: false
    t.integer "group_id"
    t.integer "user_id"
    t.integer "creator_id",  null: false
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
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

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
    t.boolean  "finished_intro",                      default: false
    t.text     "r"
    t.text     "access_tokens"
    t.integer  "follows_email",                       default: 0,     null: false
    t.boolean  "follows_mobile",                      default: true,  null: false
    t.integer  "memberships_email",                   default: 1,     null: false
    t.boolean  "memberships_mobile",                  default: true,  null: false
    t.integer  "created_email",                       default: 1,     null: false
    t.boolean  "created_mobile",                      default: true,  null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "birthday"
    t.datetime "last_accepted"
    t.boolean  "has_analytics",                       default: true
    t.text     "omni_info"
    t.integer  "gender"
    t.integer  "hometown"
    t.string   "time_zone",                           default: "UTC"
    t.string   "language",                            default: "nl"
    t.string   "country",                             default: "NL"
    t.integer  "failed_attempts",                     default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "notifications_viewed_at"
    t.integer  "decisions_email",                     default: 3,     null: false
    t.integer  "news_email",                          default: 3,     null: false
    t.integer  "reactions_email",                     default: 3,     null: false
    t.boolean  "has_drafts",                          default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "voteable_id",                           null: false
    t.string   "voteable_type", limit: 255,             null: false
    t.integer  "voter_id",                              null: false
    t.string   "voter_type",    limit: 255
    t.integer  "for",                       default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.integer  "publisher_id",                          null: false
    t.index ["voteable_id", "voteable_type", "voter_id"], name: "index_votes_on_voteable_id_and_voteable_type_and_voter_id", unique: true, using: :btree
    t.index ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type", using: :btree
    t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree
  end

  add_foreign_key "access_tokens", "profiles"
  add_foreign_key "arguments", "profiles", column: "creator_id"
  add_foreign_key "arguments", "users", column: "publisher_id"
  add_foreign_key "banners", "forums", on_delete: :cascade
  add_foreign_key "blog_posts", "forums"
  add_foreign_key "blog_posts", "profiles", column: "creator_id"
  add_foreign_key "blog_posts", "users", column: "publisher_id"
  add_foreign_key "comments", "forums"
  add_foreign_key "comments", "profiles", column: "creator_id"
  add_foreign_key "comments", "users", column: "publisher_id"
  add_foreign_key "decisions", "edges", column: "decisionable_id"
  add_foreign_key "decisions", "forums"
  add_foreign_key "decisions", "groups", column: "forwarded_group_id"
  add_foreign_key "decisions", "profiles", column: "creator_id"
  add_foreign_key "decisions", "users", column: "forwarded_user_id"
  add_foreign_key "decisions", "users", column: "publisher_id"
  add_foreign_key "edges", "edges", column: "parent_id"
  add_foreign_key "edges", "users"
  add_foreign_key "favorites", "edges"
  add_foreign_key "favorites", "users"
  add_foreign_key "follows", "edges", column: "followable_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "forums", "pages"
  add_foreign_key "forums", "places"
  add_foreign_key "grants", "edges"
  add_foreign_key "grants", "groups"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "profiles"
  add_foreign_key "group_memberships", "profiles", column: "member_id"
  add_foreign_key "group_responses", "users", column: "publisher_id"
  add_foreign_key "groups", "forums"
  add_foreign_key "groups", "pages"
  add_foreign_key "identities", "users"
  add_foreign_key "motions", "forums"
  add_foreign_key "motions", "places"
  add_foreign_key "motions", "profiles", column: "creator_id"
  add_foreign_key "motions", "projects"
  add_foreign_key "motions", "questions"
  add_foreign_key "motions", "users", column: "publisher_id"
  add_foreign_key "notifications", "activities"
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "pages", "profiles", column: "owner_id"
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
  add_foreign_key "questions", "profiles", column: "creator_id"
  add_foreign_key "questions", "projects"
  add_foreign_key "questions", "users", column: "publisher_id"
  add_foreign_key "rules", "edges", column: "branch_id"
  add_foreign_key "shortnames", "forums"
  add_foreign_key "stepups", "forums"
  add_foreign_key "stepups", "groups"
  add_foreign_key "stepups", "profiles", column: "creator_id"
  add_foreign_key "stepups", "users"
  add_foreign_key "votes", "profiles", column: "voter_id"
  add_foreign_key "votes", "users", column: "publisher_id"
end
