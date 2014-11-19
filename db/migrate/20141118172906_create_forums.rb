class CreateForums < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :display_name, unique: true
      t.timestamps null: false
    end

    rename_table :statements, :motions
    rename_column :arguments, :statement_id, :motion_id
    rename_column :opinions, :statement_id, :motion_id
    rename_column :question_answers, :statement_id, :motion_id

    create_table :forums do |t|
      t.string  :display_name, unique: true

      t.belongs_to :page

      t.integer :questions_count, :null => false, :default => 0
      t.integer :motions_count, :null => false, :default => 0
      t.integer :memberships_count, :null => false, :default => 0

      t.string  :profile_photo
      t.string  :cover_photo

      t.timestamps null: false
    end

    rename_column :memberships, :organisation_id, :forum_id

    drop_table :organisations
    drop_table :groups
    drop_table :group_memberships
    drop_table :profiles_roles
  end
end
