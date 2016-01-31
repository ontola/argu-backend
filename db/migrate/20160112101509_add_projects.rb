class AddProjects < ActiveRecord::Migration
  def up

    create_table :places do |t|
      t.string  :licence
      t.string  :osm_type
      t.integer :osm_id, limit: 8
      t.text    :boundingbox, array: true, default: []
      t.decimal :lat, precision: 64, scale: 12
      t.decimal :lon, precision: 64, scale: 12
      t.string  :display_name
      t.string  :osm_class
      t.string  :osm_type
      t.string  :osm_importance
      t.string  :icon
    end
    change_column :places, :id, :bigint, null: false, unique: true
    add_column :questions, :place_id, :bigint
    add_foreign_key :questions, :places
    add_column :motions, :place_id, :bigint
    add_foreign_key :motions, :places
    add_column :forums, :place_id, :bigint
    add_foreign_key :forums, :places


    create_table :placements do |t|
      t.belongs_to :forum, null: false
      t.belongs_to :place, null: false
      t.belongs_to :placeable, null: false, polymorphic: true
      t.string     :title
      t.text       :about
      t.integer    :creator_id,  null: false
      t.integer    :publisher_id
    end
    add_index :placements, :forum_id
    add_foreign_key :placements, :places
    add_foreign_key :placements, :forums
    add_foreign_key :placements, :users,    column: :publisher_id
    add_foreign_key :placements, :profiles, column: :creator_id


    create_table :projects do |t|
      t.belongs_to :forum, null: false
      t.integer    :creator_id,  null: false
      t.integer    :publisher_id
      t.integer    :group_id
      t.integer    :state,       null: false, default: 0
      t.string     :title,       null: false
      t.text       :content
      t.datetime   :start_date
      t.string     :email
      t.datetime   :end_date
      t.datetime   :achieved_end_date
      t.integer    :questions_count, default: 0, null: false
      t.integer    :motions_count, default: 0, null: false
      t.integer    :phases_count, default: 0, null: false
      t.datetime   :published_at
      t.datetime   :trashed_at
      t.timestamps null: false
    end
    add_index :projects, :forum_id
    add_index :projects, [:forum_id, :trashed_at]
    add_foreign_key :projects, :forums
    add_foreign_key :projects, :users,    column: :publisher_id
    add_foreign_key :projects, :profiles, column: :creator_id
    add_foreign_key :projects, :groups


    create_table :phases do |t|
      t.belongs_to :forum, null: false
      t.belongs_to :project, null: false
      t.integer    :creator_id,  null: false
      t.integer    :publisher_id
      t.integer    :position
      t.string     :name
      t.text       :description
      t.datetime   :start_date
      t.datetime   :end_date
      t.timestamps null: false
    end
    add_index :phases, [:forum_id, :project_id]
    add_foreign_key :phases, :forums
    add_foreign_key :phases, :projects
    add_foreign_key :phases, :users,    column: :publisher_id
    add_foreign_key :phases, :profiles, column: :creator_id


    add_column :questions, :project_id, :integer
    add_foreign_key :questions, :projects


    change_table :motions do |t|
      t.belongs_to :project
    end
    add_foreign_key :motions, :projects

    change_table :groups do |t|
      t.integer    :visibility, default: 0
      t.boolean    :deletable, default: true
      t.text       :description
    end

    create_table :stepups do |t|
      t.belongs_to :forum, null: false
      t.belongs_to :record, polymorphic: true, null: false
      t.belongs_to :group
      t.belongs_to :user
      t.belongs_to :creator
      t.string     :title
      t.text       :description
    end
    add_foreign_key :stepups, :forums
    add_foreign_key :stepups, :groups
    add_foreign_key :stepups, :users
    add_foreign_key :stepups, :profiles, column: :creator_id


    change_table :group_memberships do |t|
      t.string   :title
      t.text     :description
      t.datetime :start_date
      t.datetime :end_date
    end


    create_table :blog_posts do |t|
      t.belongs_to :forum, null: false
      t.belongs_to :blog_postable, polymorphic: true, nil: false
      t.integer    :creator_id,  null: false
      t.integer    :publisher_id
      t.integer    :state,       null: false, default: 0
      t.string     :title,       null: false
      t.text       :content
      t.integer    :comments_count, default: 0, null: false
      t.datetime   :published_at
      t.datetime   :trashed_at
      t.timestamps null: false
    end
    add_foreign_key :blog_posts, :forums
    add_foreign_key :blog_posts, :users,    column: :publisher_id
    add_foreign_key :blog_posts, :profiles, column: :creator_id
    add_index :blog_posts, [:id, :forum_id]
    add_index :blog_posts, [:forum_id, :published_at]
    add_index :blog_posts, [:forum_id, :trashed_at]


    create_table :photos do |t|
      t.belongs_to :forum, null: false
      t.belongs_to :about, polymorphic: true, null: false
      t.integer    :used_as, default: 0
      t.belongs_to :creator
      t.belongs_to :publisher
      t.string     :image_uid
      t.string     :title
      t.text       :description
      t.timestamp  :date_created
      t.timestamps null: false
    end
    add_index :photos, :forum_id
    add_index :photos, [:about_id, :about_type]
    add_foreign_key :photos, :forums
    add_foreign_key :photos, :users,    column: :publisher_id
    add_foreign_key :photos, :profiles, column: :creator_id


    add_column :forums, :projects_count, :integer, default: 0, null: false

    add_column :comments, :forum_id, :integer
    Comment.find_each do |comment|
      if comment.commentable.present?
        comment.update forum_id: comment.commentable.forum_id
      else
        Rails.logger.info "Comment #{comment.id} abandoned"
        say "Comment #{comment.id} abandoned"
      end
    end
    add_foreign_key :comments, :forums

  end

  def down
    remove_column :questions, :place_id
    remove_column :motions, :place_id
    remove_column :forums, :place_id

    remove_column :questions, :project_id
    remove_column :motions, :project_id

    drop_table :phases
    drop_table :projects

    remove_column :groups, :visibility
    remove_column :groups, :deletable
    remove_column :groups, :description

    drop_table :stepups

    remove_column :group_memberships, :title
    remove_column :group_memberships, :description
    remove_column :group_memberships, :start_date
    remove_column :group_memberships, :end_date

    drop_table :blog_posts
    drop_table :photos

    drop_table :placements
    drop_table :places

    remove_column :forums, :projects_count

    remove_column :comments, :forum_id
  end
end
