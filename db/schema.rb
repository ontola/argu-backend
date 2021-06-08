# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_08_092538) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "hstore"
  enable_extension "ltree"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.string "trackable_type", null: false
    t.integer "owner_id"
    t.string "owner_type", default: "Profile"
    t.ltree "key"
    t.text "parameters"
    t.string "recipient_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "audit_data"
    t.string "comment"
    t.uuid "trackable_edge_id"
    t.uuid "recipient_edge_id"
    t.uuid "root_id", null: false
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["key"], name: "index_activities_on_key", using: :gist
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_edge_id"], name: "index_activities_on_recipient_edge_id"
    t.index ["root_id", "key"], name: "index_activities_on_root_id_and_key"
    t.index ["root_id"], name: "index_activities_on_root_id"
    t.index ["trackable_edge_id"], name: "index_activities_on_trackable_edge_id"
  end

  create_table "custom_menu_items", force: :cascade do |t|
    t.string "menu_type", null: false
    t.string "resource_type", null: false
    t.integer "order", null: false
    t.string "label"
    t.boolean "label_translation", default: false, null: false
    t.string "image"
    t.string "href"
    t.string "policy"
    t.uuid "resource_id", null: false
    t.uuid "edge_id"
    t.uuid "root_id", null: false
    t.integer "parent_menu_id"
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
    t.integer "publisher_id", null: false
    t.integer "parent_id"
    t.string "owner_type"
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
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.boolean "confirmed", default: false, null: false
    t.uuid "root_id", null: false
    t.integer "fragment", null: false
    t.integer "creator_id", null: false
    t.boolean "primary"
    t.integer "attachments_count", default: 0, null: false
    t.index ["is_published"], name: "index_edges_on_is_published"
    t.index ["owner_type"], name: "index_edges_on_owner_type"
    t.index ["parent_id", "creator_id"], name: "index_edges_on_parent_id_and_creator_id", unique: true, where: "(\"primary\" IS TRUE)"
    t.index ["path"], name: "index_edges_on_path", using: :gist
    t.index ["root_id", "fragment"], name: "index_edges_on_root_id_and_fragment", unique: true
    t.index ["root_id", "path"], name: "index_edges_on_root_id_and_path"
    t.index ["root_id"], name: "index_edges_on_root_id"
    t.index ["trashed_at"], name: "index_edges_on_trashed_at"
    t.index ["uuid"], name: "index_edges_on_uuid", unique: true
  end

  create_table "email_addresses", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "email"
    t.boolean "primary", default: false, null: false
    t.string "unconfirmed_email"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["email"], name: "index_email_addresses_on_email", unique: true
  end

  create_table "exports", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "status", default: 0, null: false
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "edge_id", null: false
    t.index ["edge_id"], name: "index_exports_on_edge_id"
  end

  create_table "follows", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "followable_type", default: "Edge", null: false
    t.integer "follower_id", null: false
    t.string "follower_type", default: "User", null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "send_email", default: false
    t.integer "follow_type", default: 30, null: false
    t.uuid "followable_id", null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
    t.index ["follower_type", "follower_id", "followable_type", "followable_id"], name: "index_follower_followable", unique: true
  end

  create_table "grant_resets", force: :cascade do |t|
    t.string "resource_type", null: false
    t.string "action", null: false
    t.uuid "edge_id", null: false
    t.index ["edge_id", "resource_type", "action"], name: "index_grant_resets_on_edge_id_and_resource_type_and_action", unique: true
  end

  create_table "grant_sets", force: :cascade do |t|
    t.string "title"
    t.uuid "root_id"
    t.index ["root_id"], name: "index_grant_sets_on_root_id"
    t.index ["title", "root_id"], name: "index_grant_sets_on_title_and_root_id", unique: true
  end

  create_table "grant_sets_permitted_actions", force: :cascade do |t|
    t.integer "grant_set_id", null: false
    t.integer "permitted_action_id", null: false
    t.index ["grant_set_id"], name: "index_grant_sets_permitted_actions_on_grant_set_id"
    t.index ["permitted_action_id"], name: "index_grant_sets_permitted_actions_on_permitted_action_id"
  end

  create_table "grants", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grant_set_id"
    t.uuid "edge_id", null: false
    t.index ["edge_id"], name: "index_grants_on_edge_id"
    t.index ["grant_set_id"], name: "index_grants_on_grant_set_id"
    t.index ["group_id", "edge_id"], name: "index_grants_on_group_id_and_edge_id", unique: true
    t.index ["group_id"], name: "index_grants_on_group_id"
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
    t.string "name", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name_singular", null: false
    t.boolean "deletable", default: true
    t.uuid "root_id", null: false
    t.boolean "require_2fa", default: false
    t.index ["root_id", "name"], name: "index_groups_on_root_id_and_name", unique: true
    t.index ["root_id", "name_singular"], name: "index_groups_on_root_id_and_name_singular", unique: true
    t.index ["root_id"], name: "index_groups_on_root_id"
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

  create_table "media_objects", id: :serial, force: :cascade do |t|
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
    t.string "remote_url"
    t.uuid "about_id", null: false
    t.uuid "forum_id"
    t.index ["about_id", "about_type"], name: "index_media_objects_on_about_id_and_about_type"
    t.index ["content_attributes"], name: "index_media_objects_on_content_attributes", using: :gin
    t.index ["forum_id"], name: "index_media_objects_on_forum_id"
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
    t.uuid "root_id", null: false
    t.index ["activity_id"], name: "index_notifications_on_activity_id"
    t.index ["root_id"], name: "index_notifications_on_root_id"
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
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "otp_secrets", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id", null: false
    t.string "otp_secret_key", null: false
    t.boolean "active", default: false
  end

  create_table "permitted_actions", force: :cascade do |t|
    t.string "title"
    t.string "resource_type", null: false
    t.string "parent_type", null: false
    t.string "action", null: false
    t.index ["action"], name: "index_permitted_actions_on_action"
    t.index ["parent_type"], name: "index_permitted_actions_on_parent_type"
    t.index ["resource_type"], name: "index_permitted_actions_on_resource_type"
    t.index ["title"], name: "index_permitted_actions_on_title", unique: true
  end

  create_table "placements", id: :serial, force: :cascade do |t|
    t.integer "place_id", null: false
    t.string "placeable_type", null: false
    t.string "title"
    t.text "about"
    t.integer "creator_id", null: false
    t.integer "publisher_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "placement_type", null: false
    t.uuid "placeable_id", null: false
    t.uuid "forum_id"
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
    t.boolean "is_public", default: true
    t.boolean "are_votes_public", default: true
    t.string "profileable_type"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.uuid "profileable_id", null: false
    t.index ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable_type_and_profileable_id", unique: true
    t.index ["uuid"], name: "index_profiles_on_uuid", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "edge_id", null: false
    t.string "predicate", null: false
    t.boolean "boolean"
    t.string "string"
    t.text "text"
    t.datetime "datetime"
    t.bigint "integer"
    t.uuid "linked_edge_id"
    t.integer "order", default: 0, null: false
    t.string "iri"
    t.string "language"
    t.uuid "root_id", null: false
    t.index ["edge_id", "predicate", "integer"], name: "index_properties_on_edge_id_and_predicate_and_integer"
    t.index ["edge_id"], name: "index_properties_on_edge_id"
    t.index ["root_id", "edge_id", "linked_edge_id", "predicate", "order"], name: "order_index"
    t.index ["root_id", "edge_id"], name: "index_properties_on_root_id_and_edge_id"
    t.index ["root_id"], name: "index_properties_on_root_id"
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.string "job_id"
    t.datetime "published_at"
    t.string "channel"
    t.integer "creator_id", null: false
    t.integer "publisher_id"
    t.integer "follow_type", default: 3, null: false
    t.uuid "publishable_id"
    t.index ["publishable_id"], name: "index_publications_on_publishable_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "shortnames", id: :serial, force: :cascade do |t|
    t.string "shortname", null: false
    t.string "owner_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "owner_id", null: false
    t.uuid "root_id"
    t.boolean "primary", default: true, null: false
    t.index "lower((shortname)::text)", name: "index_shortnames_on_unscoped_shortname", unique: true, where: "(root_id IS NULL)"
    t.index "lower((shortname)::text), root_id", name: "index_shortnames_on_scoped_shortname", unique: true
    t.index ["owner_id", "owner_type"], name: "index_shortnames_on_owner_id_and_owner_type", unique: true, where: "(\"primary\" IS TRUE)"
    t.index ["root_id"], name: "index_shortnames_on_root_id"
  end

  create_table "spam_verdicts", force: :cascade do |t|
    t.boolean "verdict", null: false
    t.text "content"
    t.string "email"
    t.hstore "http_headers"
    t.string "ip"
    t.string "referrer"
    t.string "user_agent"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "iri_prefix", null: false
    t.string "database_schema", default: "argu", null: false
    t.uuid "root_id", null: false
    t.index ["iri_prefix"], name: "index_tenants_on_iri_prefix", unique: true
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
    t.text "redirect_url"
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
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.string "iri_cache"
    t.boolean "hide_last_name", default: false
    t.boolean "is_public", default: true
    t.boolean "show_feed", default: true
    t.text "about", default: ""
    t.integer "attachments_count", default: 0, null: false
    t.string "display_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["show_feed"], name: "index_users_on_show_feed"
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  create_table "widgets", force: :cascade do |t|
    t.integer "widget_type", null: false
    t.string "owner_type", null: false
    t.text "resource_iri", null: false, array: true
    t.integer "size", default: 1, null: false
    t.integer "position", null: false
    t.uuid "owner_id", null: false
    t.integer "permitted_action_id", null: false
    t.uuid "root_id", null: false
    t.integer "view", default: 0, null: false
    t.index ["owner_id", "owner_type"], name: "index_widgets_on_owner_id_and_owner_type"
  end

  add_foreign_key "activities", "edges", column: "recipient_edge_id", primary_key: "uuid"
  add_foreign_key "activities", "edges", column: "trackable_edge_id", primary_key: "uuid"
  add_foreign_key "custom_menu_items", "edges", primary_key: "uuid"
  add_foreign_key "edges", "edges", column: "parent_id"
  add_foreign_key "edges", "profiles", column: "creator_id"
  add_foreign_key "edges", "users", column: "publisher_id"
  add_foreign_key "email_addresses", "users"
  add_foreign_key "exports", "edges", primary_key: "uuid"
  add_foreign_key "exports", "users"
  add_foreign_key "follows", "edges", column: "followable_id", primary_key: "uuid"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "grant_resets", "edges", primary_key: "uuid"
  add_foreign_key "grant_sets", "edges", column: "root_id", primary_key: "uuid"
  add_foreign_key "grant_sets_permitted_actions", "grant_sets"
  add_foreign_key "grant_sets_permitted_actions", "permitted_actions"
  add_foreign_key "grants", "edges", primary_key: "uuid"
  add_foreign_key "grants", "grant_sets"
  add_foreign_key "grants", "groups"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "profiles", column: "member_id"
  add_foreign_key "groups", "edges", column: "root_id", primary_key: "uuid"
  add_foreign_key "identities", "users"
  add_foreign_key "media_objects", "edges", column: "forum_id", primary_key: "uuid"
  add_foreign_key "media_objects", "profiles", column: "creator_id"
  add_foreign_key "media_objects", "users", column: "publisher_id"
  add_foreign_key "notifications", "activities"
  add_foreign_key "notifications", "edges", column: "root_id", primary_key: "uuid"
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "placements", "edges", column: "forum_id", primary_key: "uuid"
  add_foreign_key "placements", "places"
  add_foreign_key "placements", "profiles", column: "creator_id"
  add_foreign_key "placements", "users", column: "publisher_id"
  add_foreign_key "publications", "edges", column: "publishable_id", primary_key: "uuid"
end
