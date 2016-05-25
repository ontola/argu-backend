class VoteSerializer < BaseSerializer
  attributes :id, :created_at, :key, :side
  has_one :opinion
  has_one :voter

  def key
    object.identifier
  end

  def opinion
    Opinion.where(motion_id: object.voteable_id, creator_id: object.voter_id).order(created_at: :asc).last
  end

  def side
    object.for
  end
end
