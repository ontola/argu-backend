class RefactorFollowing < ActiveRecord::Migration
  def up
    Follow.pluck(:followable_type).uniq.each do |klass|
      Follow
        .where(followable_type: klass)
        .joins("FULL OUTER JOIN #{klass.tableize} ON follows.followable_id=#{klass.tableize}.id")
        .where("#{klass.tableize}.id IS NULL").destroy_all
    end

    change_column :follows, :followable_type, :string, default: 'Edge'
    change_column :follows, :follower_type, :string, default: 'User'
    add_foreign_key :follows, :edges, column: :followable_id
    add_foreign_key :follows, :users, column: :follower_id

    Follow.find_each do |f|
      f.update(followable_type: 'Ltree::Models::Edge',
               followable_id: f.followable_type.constantize.find(f.followable_id).edge.id)
    end
  end

  def down
    change_column :follows, :followable_type, :string, default: nil
    change_column :follows, :follower_type, :string, default: nil
    remove_foreign_key :follows, column: :followable_id
    remove_foreign_key :follows, column: :follower_id

    Follow.find_each do |f|
      f.update(followable_type: f.followable.owner.class.to_s,
               followable_id: f.followable.owner.id)
    end
  end
end
