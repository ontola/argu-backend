class MoveUnconfirmedVotesToPg < ActiveRecord::Migration[5.1]
  def change
    add_column :edges, :confirmed, :bool, null: false, default: false

    guest_votes = Argu::Redis.keys('temporary.guest_user*').count
    unconfirmed_votes = Argu::Redis.keys('temporary.user*').count
    votes = Vote.count

    Argu::Redis.keys('temporary.user*').each do |key|
      parsed_key = RedisResource::Key.parse(key)
      if parsed_key
        parsed_key.redis_resource.persist(parsed_key.user)
      else
        Argu::Redis.delete(key)
      end
    end

    puts "Migrated #{Vote.count - votes} out of #{unconfirmed_votes} unconfirmed votes"
    if Argu::Redis.keys('temporary.guest_user*').count != guest_votes
      raise "Found #{Argu::Redis.keys('temporary.guest_user*').count} instead of #{guest_votes} guest votes after migration"
    end
    if Argu::Redis.keys('temporary.user*').count > 0
      raise "Found #{Argu::Redis.keys('temporary.user*').count} unconfirmed votes after migration"
    end

    Edge
      .joins(user: :email_addresses)
      .where('email_addresses.confirmed_at IS NOT NULL OR edges.created_at < ?', DateTime.parse('17-07-2017'))
      .update_all(confirmed: true)
  end
end
