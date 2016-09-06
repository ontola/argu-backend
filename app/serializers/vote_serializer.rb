class VoteSerializer < BaseSerializer
  attributes :id, :forum
  attribute :for, key: :side
  has_one :voteable
  has_one :voter

  def voter
    object.voter.profileable
  end
end
