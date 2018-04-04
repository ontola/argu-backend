class CreateCommentsFromOpinions < ActiveRecord::Migration[5.1]
  def change
    RedisResource::EdgeRelation.where(owner_type: 'Vote').select { |edge| edge.owner.explanation.present? }.map(&:owner).each do |vote|
      link_comment(vote)
    end

    Vote.where('votes.explanation IS NOT NULL AND votes.explanation != \'\'').find_each do |vote|
      link_comment(vote)
    end
  end

  private

  def create_comment(vote)
    service = CreateComment.new(
      vote.voteable.edge,
      attributes: {created_at: vote.explained_at, content: vote.explanation},
      options: {publisher: vote.publisher, creator: vote.creator, silent: true}
    )
    service.on(:create_comment_failed) do |c|
      raise "Failed to create comment: #{c.errors.full_messages}"
    end
    service.commit
    service.resource
  end

  def link_comment(vote)
    return if vote.explanation.strip.length < 4
    comment =
      Comment.find_by(publisher: vote.publisher, creator: vote.creator, content: vote.explanation) || create_comment(vote)
    vote.update!(comment_id: comment.id)
  end
end
