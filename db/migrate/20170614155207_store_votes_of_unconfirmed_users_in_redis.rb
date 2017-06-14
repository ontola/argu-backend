class StoreVotesOfUnconfirmedUsersInRedis < ActiveRecord::Migration[5.0]
  def up
    pre_count = Argu::Redis.keys('temporary.*').count
    votes_to_store = Vote.joins(publisher: :emails).where('emails.confirmed_at IS NULL')
    votes_to_store.find_each do |vote|
      key = RedisResource::Key.new(
        path: vote.parent_edge.path,
        owner_type: 'Vote',
        user: vote.publisher,
        edge_id: vote.edge.id
      )
      Argu::Redis.set(key.key, vote.attributes.merge(persisted: true).to_json)
    end
    if (Argu::Redis.keys('temporary.*').count - pre_count) != votes_to_store.count
      raise "Missing #{votes_to_store.count - (Argu::Redis.keys('temporary.*').count - pre_count)} redis keys"
    end
  end
end
