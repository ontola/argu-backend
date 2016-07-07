class UpdateVotesIndex < ActiveRecord::Migration
  def change
    remove_index :votes, name: 'index_votes_on_voter_and_voteable_and_trashed'
    remove_index :votes, name: 'no_duplicate_votes'

    dup_count =
      Vote.count - Vote
                     .group(:voter_id, :voteable_type, :voteable_id)
                     .select(:voter_id, :voteable_type, :voteable_id)
                     .uniq
                     .length
    tuples = ActiveRecord::Base.connection.execute(
      'SELECT voter_id, voteable_type, voteable_id, COUNT(*)'\
        ' FROM votes GROUP BY voter_id, voteable_type, voteable_id'\
        ' HAVING COUNT(*) > 1')
    sql_dup_count = tuples.map { |v| v['count'].to_i }.reduce(&:+) - tuples.ntuples

    unless dup_count == sql_dup_count
      raise "Error in one of the queries (#{dup_count}/#{sql_dup_count})"
    end

    destroyed = 0
    tuples.each do |tuple|
      clause = tuple.dup
      count = clause.delete('count')
      votes = Vote.where(clause)[1..-1]
      raise 'One vote should remain' unless votes.count == count.to_i - 1
      votes.each { |v| raise(v.errors.full_messages) unless v.destroy }
      destroyed += votes.count
    end
    unless destroyed == sql_dup_count
      raise "Incorrect number of votes destroyed (#{destroyed}/#{sql_dup_count})"
    end

    change_column_null :votes, :voteable_id, false
    change_column_null :votes, :voteable_type, false
    change_column_null :votes, :voter_id, false
    add_index :votes, %w(voteable_id voteable_type voter_id), unique: true
  end
end
