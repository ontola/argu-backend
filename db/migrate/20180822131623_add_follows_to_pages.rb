class AddFollowsToPages < ActiveRecord::Migration[5.2]
  def change
    Follow.joins(:followable).where(edges: {owner_type: 'Page'}).destroy_all
    follows = Follow.joins(:followable).where(edges: {owner_type: 'Forum'}).where('follow_type > ?', 0).pluck('follows.follower_id, edges.root_id').uniq
    Follow.connection.update("INSERT INTO follows (follower_id, followable_id, follow_type) VALUES #{follows.map { |follower, edge| "(#{follower}, '#{edge}', #{Follow.follow_types[:news]})" }.join(', ') }")
    Follow.counter_culture_fix_counts
  end
end
