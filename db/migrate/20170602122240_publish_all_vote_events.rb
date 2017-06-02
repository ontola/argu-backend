class PublishAllVoteEvents < ActiveRecord::Migration[5.0]
  def up
    Edge.where(owner_type: 'VoteEvent').update_all(is_published: true)
  end
end
