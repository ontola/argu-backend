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

ActiveRecord::Schema.define(version: 20170911102831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gist"
  enable_extension "hstore"
  enable_extension "ltree"
  enable_extension "uuid-ossp"

  create_table "access_tokens", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.string "item_type"
    t.string "access_token", null: false
    t.integer "profile_id", null: false
    t.integer "usages", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_ups", default: 0
    t.index ["access_token"], name: "index_access_tokens_on_access_token"
    t.index ["item_id", "item_type"], name: "index_access_tokens_on_item_id_and_item_type"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "trackable_id"
    t.string "trackable_type"
    t.integer "forum_id"
    t.integer "owner_id"
    t.string "owner_type", default: "Profile"
    t.ltree "key"
    t.text "parameters"
    t.integer "recipient_id"
    t.string "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "audit_data"
    t.integer "trackable_edge_id"
    t.integer "recipient_edge_id"
    t.string "comment"
    t.index ["forum_id", "owner_id", "owner_type"], name: "index_activities_on_forum_id_and_owner_id_and_owner_type"
    t.index ["forum_id", "trackable_id", "trackable_type"], name: "forum_trackable"
    t.index ["forum_id"], name: "index_activities_on_forum_id"
    t.index ["key"], name: "index_activities_on_key", using: :gist
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.integer "publisher_id"
    t.string "title"
    t.text "content"
    t.integer "audience", default: 0, null: false
    t.integer "sample_size", default: 100, null: false
    t.boolean "dismissable", default: true, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "trashed_at"
    t.datetime "ends_at"
    t.index ["published_at"], name: "index_announcements_on_published_at"
  end

  create_table "arguments", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "motion_id"
    t.boolean "pro", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", limit: 255
    t.integer "creator_id", null: false
    t.integer "forum_id"
    t.integer "publisher_id", null: false
    t.index ["id"], name: "index_arguments_on_id"
    t.index ["motion_id", "id", "pro"], name: "index_arguments_on_motion_id_and_id_and_pro"
    t.index ["motion_id", "id"], name: "index_arguments_on_motion_id_and_id"
    t.index ["motion_id"], name: "statement_id"
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", limit: 255, null: false
    t.string "uid", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "uid"], name: "user_id_and_uid", unique: true
    t.index ["user_id"], name: "user_id"
  end

  create_table "banners", id: :serial, force: :cascade do |t|
    t.string "type"
    t.integer "forum_id"
    t.integer "publisher_id"
    t.string "title"
    t.text "content"
    t.integer "cited_profile_id"
    t.string "cited_avatar"
    t.string "cited_name"
    t.string "cited_function"
    t.integer "audience", default: 0, null: false
    t.integer "sample_size", default: 100, null: false
    t.boolean "dismissable", default: true, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "trashed_at"
    t.datetime "ends_at"
    t.index ["forum_id", "published_at"], name: "index_banners_on_forum_id_and_published_at"
    t.index ["forum_id"], name: "index_banners_on_forum_id"
  end

  create_table "blog_posts", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "blog_postable_id"
    t.string "blog_postable_type"
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.integer "state", default: 0, null: false
    t.string "title", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false, null: false
    t.index ["forum_id", "is_published"], name: "index_blog_posts_on_forum_id_and_is_published"
    t.index ["id", "forum_id"], name: "index_blog_posts_on_id_and_forum_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id", default: 0
    t.string "commentable_type", limit: 255, default: ""
    t.string "title", limit: 255, default: ""
    t.text "body", default: ""
    t.string "subject", limit: 255, default: ""
    t.integer "creator_id", default: 0, null: false
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "publisher_id", null: false
    t.integer "forum_id"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["creator_id"], name: "index_comments_on_creator_id"
  end

  create_table "decisions", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "decisionable_id", null: false
    t.integer "forwarded_group_id"
    t.integer "forwarded_user_id"
    t.integer "publisher_id", null: false
    t.integer "creator_id", null: false
    t.integer "step", default: 0, null: false
    t.text "content", default: "", null: false
    t.integer "state", default: 0, null: false
    t.boolean "is_published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_documents_on_name"
  end

  create_table "edges", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.ltree "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "pinned_at"
    t.datetime "last_activity_at"
    t.datetime "trashed_at"
    t.boolean "is_published", default: false
    t.hstore "children_counts", default: {}
    t.integer "follows_count", default: 0, null: false
    t.datetime "expires_at"
    t.index ["owner_type", "owner_id"], name: "index_edges_on_owner_type_and_owner_id", unique: true
  end

  create_table "edits", id: :serial, force: :cascade do |t|
    t.integer "by_id"
    t.string "by_type"
    t.integer "item_id"
    t.string "item_type"
    t.integer "action"
    t.text "custom"
    t.string "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["by_type", "by_id"], name: "index_edits_on_by_type_and_by_id"
    t.index ["item_type", "item_id"], name: "index_edits_on_item_type_and_item_id"
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email"
    t.boolean "primary", default: false, null: false
    t.string "unconfirmed_email"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["email"], name: "index_emails_on_email", unique: true
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "edge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "edge_id"], name: "index_favorites_on_user_id_and_edge_id", unique: true
  end

  create_table "follows", id: :serial, force: :cascade do |t|
    t.integer "followable_id", null: false
    t.string "followable_type", default: "Edge", null: false
    t.integer "follower_id", null: false
    t.string "follower_type", default: "User", null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "send_email", default: false
    t.integer "follow_type", default: 30, null: false
    t.index ["followable_id", "followable_type"], name: "fk_followables"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
    t.index ["follower_type", "follower_id", "followable_type", "followable_id"], name: "index_follower_followable", unique: true
  end

  create_table "forums", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "page_id"
    t.string "profile_photo"
    t.string "cover_photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "bio", default: "", null: false
    t.integer "visibility", default: 2
    t.string "cover_photo_attribution", default: ""
    t.boolean "visible_with_a_link", default: false
    t.boolean "signup_with_token?", default: false
    t.text "bio_long", default: ""
    t.integer "lock_version", default: 0
    t.bigint "place_id"
    t.integer "max_shortname_count", default: 0, null: false
    t.boolean "discoverable", default: true, null: false
    t.string "locale", default: "nl-NL"
    t.index ["slug"], name: "index_forums_on_slug", unique: true
    t.index ["visibility"], name: "index_forums_on_visibility"
  end

  create_table "grants", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "edge_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "edge_id"], name: "index_grants_on_group_id_and_edge_id", unique: true
  end

  create_table "group_memberships", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "member_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.exclude_constraint :group_memberships_exclude_overlapping, using: :gist, group_id: :equals, member_id: :equals, 'tsrange(start_date, end_date)' => :overlaps, where: '(member_id <> 0)'
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_singular"
    t.boolean "deletable", default: true
    t.integer "page_id", null: false
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "access_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider"
    t.index ["uid"], name: "index_identities_on_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "linked_records", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "source_id", null: false
    t.string "iri", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "record_type"
    t.index ["iri", "source_id", "page_id"], name: "index_linked_records_on_iri_and_source_id_and_page_id"
    t.index ["iri"], name: "index_linked_records_on_iri", unique: true
  end

  create_table "list_items", id: :serial, force: :cascade do |t|
    t.uuid "listable_id", null: false
    t.string "listable_type", null: false
    t.string "relationship", null: false
    t.integer "order", null: false
    t.string "iri", null: false
    t.string "resource_type", null: false
  end

  create_table "media_objects", id: :serial, force: :cascade do |t|
    t.integer "forum_id"
    t.integer "about_id", null: false
    t.string "about_type", null: false
    t.integer "used_as", default: 0, null: false
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.string "content_uid"
    t.string "title"
    t.text "description"
    t.datetime "date_created"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "filename"
    t.hstore "content_attributes"
    t.index ["about_id", "about_type"], name: "index_media_objects_on_about_id_and_about_type"
    t.index ["content_attributes"], name: "index_media_objects_on_content_attributes", using: :gin
    t.index ["forum_id"], name: "index_media_objects_on_forum_id"
  end

  create_table "motions", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pro_count", default: 0
    t.integer "con_count", default: 0
    t.integer "forum_id"
    t.integer "creator_id", null: false
    t.string "cover_photo", default: ""
    t.string "cover_photo_attribution", default: ""
    t.integer "publisher_id", null: false
    t.integer "question_id"
    t.bigint "place_id"
    t.integer "project_id"
    t.index ["forum_id"], name: "index_motions_on_forum_id"
    t.index ["id"], name: "index_motions_on_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "activity_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.string "url"
    t.integer "notification_type", null: false
    t.boolean "permanent", default: false, null: false
    t.datetime "send_mail_after"
    t.index ["activity_id"], name: "index_notifications_on_activity_id"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "resource_owner_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "page_memberships", id: :serial, force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "page_id", null: false
    t.integer "role", default: 0, null: false
    t.index ["page_id"], name: "index_page_memberships_on_page_id"
    t.index ["profile_id"], name: "index_page_memberships_on_profile_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "visibility", default: 1
    t.integer "owner_id"
    t.datetime "last_accepted"
    t.index ["owner_id"], name: "index_pages_on_owner_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "phases", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "project_id", null: false
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.integer "position"
    t.string "name"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id", "project_id"], name: "index_phases_on_forum_id_and_project_id"
  end

  create_table "placements", id: :serial, force: :cascade do |t|
    t.integer "forum_id"
    t.integer "place_id", null: false
    t.integer "placeable_id", null: false
    t.string "placeable_type", null: false
    t.string "title"
    t.text "about"
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "placement_type", null: false
    t.index ["forum_id"], name: "index_placements_on_forum_id"
    t.index ["placeable_id"], name: "index_placements_on_placeable_id", unique: true, where: "((placement_type = 0) AND ((placeable_type)::text = 'User'::text))"
  end

  create_table "places", force: :cascade do |t|
    t.string "licence"
    t.string "osm_type"
    t.bigint "osm_id"
    t.text "boundingbox", default: [], array: true
    t.decimal "lat", precision: 64, scale: 12
    t.decimal "lon", precision: 64, scale: 12
    t.string "display_name"
    t.string "osm_class"
    t.string "osm_importance"
    t.string "icon"
    t.string "osm_category"
    t.json "address"
    t.json "extratags"
    t.json "namedetails"
    t.integer "nominatim_id"
    t.integer "zoom_level", default: 13, null: false
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: ""
    t.text "about", default: ""
    t.string "picture", limit: 255, default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_photo", limit: 255
    t.string "cover_photo", limit: 255
    t.string "slug"
    t.boolean "is_public", default: true
    t.boolean "are_votes_public", default: true
    t.string "profileable_type"
    t.integer "profileable_id"
    t.index ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable_type_and_profileable_id", unique: true
    t.index ["slug"], name: "index_profiles_on_slug", unique: true
  end

  create_table "profiles_roles", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["profile_id", "role_id"], name: "index_profiles_roles_on_profile_id_and_role_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.integer "forum_id", null: false
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.integer "group_id"
    t.integer "state", default: 0, null: false
    t.string "title", null: false
    t.text "content"
    t.datetime "start_date"
    t.string "email"
    t.datetime "end_date"
    t.datetime "achieved_end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_photo", default: ""
    t.string "cover_photo_attribution", default: ""
    t.boolean "is_published", default: false, null: false
    t.index ["forum_id", "is_published"], name: "index_projects_on_forum_id_and_is_published"
    t.index ["forum_id"], name: "index_projects_on_forum_id"
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.string "job_id"
    t.datetime "published_at"
    t.integer "publishable_id"
    t.string "publishable_type", default: "Edge"
    t.string "channel"
    t.integer "creator_id", null: false
    t.integer "publisher_id"
    t.integer "follow_type", default: 3, null: false
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255, default: ""
    t.text "content", default: ""
    t.integer "forum_id"
    t.integer "creator_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "cover_photo", default: ""
    t.string "cover_photo_attribution", default: ""
    t.datetime "expires_at"
    t.integer "publisher_id", null: false
    t.bigint "place_id"
    t.integer "project_id"
    t.boolean "require_location", default: false, null: false
    t.index ["forum_id"], name: "index_questions_on_forum_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "resource_id"
    t.string "resource_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "rules", id: :serial, force: :cascade do |t|
    t.string "model_type"
    t.integer "model_id"
    t.string "action"
    t.string "role"
    t.boolean "permit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "context_type"
    t.integer "context_id"
    t.integer "trickles", default: 0, null: false
    t.string "message"
    t.integer "branch_id", null: false
    t.index ["branch_id"], name: "index_rules_on_branch_id"
    t.index ["context_id", "context_type"], name: "index_rules_on_context_id_and_context_type"
    t.index ["model_id", "model_type"], name: "index_rules_on_model_id_and_model_type"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "shortnames", id: :serial, force: :cascade do |t|
    t.string "shortname", null: false
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "forum_id"
    t.index "lower((shortname)::text)", name: "index_shortnames_on_shortname", unique: true
    t.index ["owner_id", "owner_type"], name: "index_shortnames_on_owner_id_and_owner_type", unique: true
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "page_id", null: false
    t.string "iri_base", null: false
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.integer "visibility", default: 2
    t.string "shortname", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iri_base"], name: "index_sources_on_iri_base", unique: true
    t.index ["page_id", "shortname"], name: "index_sources_on_page_id_and_shortname", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: ""
    t.string "encrypted_password", limit: 255, default: ""
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unconfirmed_email", limit: 255
    t.boolean "finished_intro", default: false
    t.text "r"
    t.text "access_tokens"
    t.integer "follows_email", default: 0, null: false
    t.boolean "follows_mobile", default: true, null: false
    t.integer "memberships_email", default: 1, null: false
    t.boolean "memberships_mobile", default: true, null: false
    t.integer "created_email", default: 1, null: false
    t.boolean "created_mobile", default: true, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "birthday"
    t.datetime "last_accepted"
    t.boolean "has_analytics", default: true
    t.text "omni_info"
    t.integer "gender"
    t.integer "hometown"
    t.string "time_zone", default: "UTC"
    t.string "language", default: "nl"
    t.string "country", default: "NL"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "notifications_viewed_at"
    t.integer "decisions_email", default: 3, null: false
    t.integer "news_email", default: 3, null: false
    t.integer "reactions_email", default: 3, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vote_events", id: :serial, force: :cascade do |t|
    t.integer "group_id", default: -1, null: false
    t.datetime "starts_at"
    t.integer "result", default: 0, null: false
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.integer "forum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_vote_events_on_group_id"
  end

  create_table "vote_matches", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "shortname"
    t.string "name", null: false
    t.text "text"
    t.integer "publisher_id", null: false
    t.integer "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "shortname"], name: "index_vote_matches_on_creator_id_and_shortname", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "voteable_id"
    t.string "voteable_type", limit: 255
    t.integer "creator_id", null: false
    t.integer "for", default: 3, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "forum_id"
    t.integer "publisher_id", null: false
    t.text "explanation"
    t.datetime "explained_at"
    t.index ["creator_id"], name: "index_votes_on_creator_id"
    t.index ["voteable_id", "voteable_type", "creator_id"], name: "index_votes_on_voteable_id_and_voteable_type_and_creator_id", unique: true
    t.index ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type"
  end

  add_foreign_key "access_tokens", "profiles"
  add_foreign_key "activities", "edges", column: "recipient_edge_id"
  add_foreign_key "activities", "edges", column: "trackable_edge_id"
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
  add_foreign_key "emails", "users"
  add_foreign_key "favorites", "edges"
  add_foreign_key "favorites", "users"
  add_foreign_key "follows", "edges", column: "followable_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "forums", "pages"
  add_foreign_key "forums", "places"
  add_foreign_key "grants", "edges"
  add_foreign_key "grants", "groups"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "profiles", column: "member_id"
  add_foreign_key "groups", "pages"
  add_foreign_key "identities", "users"
  add_foreign_key "linked_records", "pages"
  add_foreign_key "linked_records", "sources"
  add_foreign_key "media_objects", "forums"
  add_foreign_key "media_objects", "profiles", column: "creator_id"
  add_foreign_key "media_objects", "users", column: "publisher_id"
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
  add_foreign_key "placements", "forums"
  add_foreign_key "placements", "places"
  add_foreign_key "placements", "profiles", column: "creator_id"
  add_foreign_key "placements", "users", column: "publisher_id"
  add_foreign_key "projects", "forums"
  add_foreign_key "projects", "groups"
  add_foreign_key "projects", "profiles", column: "creator_id"
  add_foreign_key "projects", "users", column: "publisher_id"
  add_foreign_key "questions", "places"
  add_foreign_key "questions", "profiles", column: "creator_id"
  add_foreign_key "questions", "projects"
  add_foreign_key "questions", "users", column: "publisher_id"
  add_foreign_key "rules", "edges", column: "branch_id"
  add_foreign_key "shortnames", "forums"
  add_foreign_key "sources", "pages"
  add_foreign_key "sources", "profiles", column: "creator_id"
  add_foreign_key "sources", "users", column: "publisher_id"
  add_foreign_key "vote_events", "forums"
  add_foreign_key "vote_events", "groups"
  add_foreign_key "vote_events", "profiles", column: "creator_id"
  add_foreign_key "vote_events", "users", column: "publisher_id"
  add_foreign_key "vote_matches", "profiles", column: "creator_id"
  add_foreign_key "vote_matches", "users", column: "publisher_id"
  add_foreign_key "votes", "profiles", column: "creator_id"
  add_foreign_key "votes", "users", column: "publisher_id"
end
