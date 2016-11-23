class SetLastActivityAtWhereNil < ActiveRecord::Migration[5.0]
  def change
    Edge
      .where(owner_type: %w(Vote Motion Argument Comment Forum Question BlogPost Project GroupResponse Decision))
      .where(last_activity_at: nil)
      .find_each do |edge|
      edge.update(last_activity_at: edge.owner.updated_at)
    end
  end
end
