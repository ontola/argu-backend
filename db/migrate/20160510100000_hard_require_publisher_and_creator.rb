class HardRequirePublisherAndCreator < ActiveRecord::Migration
  MIGRATIONAL_CLASSES = [Project, Question, Motion, Argument, Comment,
                         Phase, GroupResponse, Placement].freeze

  def up
    raise('Photos still contains a nil publisher_id') unless Photo.where(publisher_id: nil).count == 0

    profile_ids = Profile.pluck(:id)
    community_profile = Profile.find(0)
    # community_user = Profile.find(0)
    MIGRATIONAL_CLASSES.each do |klass|
      klass
        .where('creator_id NOT IN (?)', profile_ids)
        .update_all(creator_id: community_profile)
    end

    add_foreign_key :arguments, :profiles, column: :creator_id
    add_foreign_key :motions, :profiles, column: :creator_id
    add_foreign_key :questions, :profiles, column: :creator_id
    add_foreign_key :comments, :profiles, column: :creator_id

    MIGRATIONAL_CLASSES.each do |klass|
      klass
        .where(publisher_id: nil)
        .find_each do |record|
          say record.identifier
          user =
            if record.creator.profileable.is_a?(User)
              record.creator.profileable
            else
              record.creator.profileable.owner.profileable
            end
          raise('OMGWUT') if user.id.blank?
          record.update_column :publisher_id, user.id
        end
    end

    change_column_null :arguments, :publisher_id, false
    change_column_null :blog_posts, :publisher_id, false
    change_column_null :comments, :publisher_id, false
    change_column_null :group_responses, :publisher_id, false
    change_column_null :motions, :publisher_id, false
    change_column_null :phases, :publisher_id, false
    change_column_null :photos, :publisher_id, false
    change_column_null :placements, :publisher_id, false
    change_column_null :projects, :publisher_id, false
    change_column_null :questions, :publisher_id, false
  end

  def down
    change_column_null :arguments, :publisher_id, true
    change_column_null :blog_posts, :publisher_id, true
    change_column_null :comments, :publisher_id, true
    change_column_null :group_responses, :publisher_id, true
    change_column_null :motions, :publisher_id, true
    change_column_null :phases, :publisher_id, true
    change_column_null :photos, :publisher_id, true
    change_column_null :placements, :publisher_id, true
    change_column_null :projects, :publisher_id, true
    change_column_null :questions, :publisher_id, true
  end
end
