class FollowUniqueConstraint < ActiveRecord::Migration
  def up
    duplicates = Follow
        .select(:follower_type, :follower_id, :followable_type, :followable_id)
        .group(:follower_type, :follower_id, :followable_type, :followable_id)
        .having("count(*) > 1")

    if duplicates.present?
      duplicates.each do |r|
        attrs = r.attributes
        attrs.delete "id"
        items = Follow.where(attrs)
        items.first.destroy if items.length > 1
      end
    end

    add_index :follows,
              [:follower_type, :follower_id, :followable_type, :followable_id],
              unique: true,
              name: 'index_follower_followable'
  end
end
