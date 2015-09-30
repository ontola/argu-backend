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

    Follow.where(followable_type: 'Profile').includes(follower: :profileable).find_each do |f|
      if f.follower.is_a? Profile
        if f.follower.profileable.is_a?(User)
          f.update follower: f.follower.profileable
        else
          f.destroy!
        end
      end
    end

    add_index :follows,
              [:follower_type, :follower_id, :followable_type, :followable_id],
              unique: true,
              name: 'index_follower_followable'
  end
end
