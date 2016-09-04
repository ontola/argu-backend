class VoteSerializer < BaseSerializer
  attributes :for, :forum
  has_one :voteable
  has_one :voter
end
