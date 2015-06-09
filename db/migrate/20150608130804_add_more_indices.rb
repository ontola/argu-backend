class AddMoreIndices < ActiveRecord::Migration
  def change
    add_index :notifications, :profile_id
    add_index :notifications, [:profile_id, :created_at]
    add_index :notifications, :activity_id

    add_index :page_memberships, :page_id
    add_index :page_memberships, :profile_id

    add_index :questions, :forum_id
    add_index :questions, [:forum_id, :is_trashed]

    add_index :rules, [:context_id, :context_type]
    add_index :rules, [:model_id, :model_type]

    add_index :pages, :owner_id

    add_index :memberships, :forum_id
    add_index :memberships, [:forum_id, :role]

    add_index :identities, [:uid, :provider]
    add_index :identities, :uid

    add_index :groups, :forum_id

    add_index :forums, :visibility

    add_index :documents, :name

    add_index :access_tokens, :access_token
    add_index :access_tokens, [:item_id, :item_type]
  end
end
