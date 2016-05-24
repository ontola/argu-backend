class VoteSerializer < BaseSerializer
  attributes :id, :created_at, :key, :side
  has_one :voter

  def key
    object.identifier
  end

  def side
    object.for
  end
end
