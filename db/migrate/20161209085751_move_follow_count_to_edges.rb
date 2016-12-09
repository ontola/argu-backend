class MoveFollowCountToEdges < ActiveRecord::Migration[5.0]
  def change
    add_column :edges, :follows_count, :integer, default: 0, null: false
    counts = {}
    Edge.joins(:follows).group('edges.id').having('count(follows.id) > 0').count.each { |k,v| counts[v] ||= []; counts[v] << k }
    counts.each do |count, edge_ids|
      Edge.where(id: edge_ids).update_all(follows_count: count)
    end
  end
end
