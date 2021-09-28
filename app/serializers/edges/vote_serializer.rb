# frozen_string_literal: true

class VoteSerializer < EdgeSerializer
  has_one :creator, predicate: NS.schema.creator do |object|
    object.publisher.show_feed? ? object.creator&.profileable : User.anonymous
  end

  has_one :voteable, predicate: NS.schema.isPartOf do |object|
    object.parent.voteable
  end

  attribute :primary, predicate: NS.argu[:primaryVote]
  has_one :option, predicate: NS.schema.option do
    nil
  end
  attribute :option, predicate: NS.schema.option do |object|
    object.option&.iri || NS.argu[:abstain]
  end
  attribute :display_name, predicate: NS.schema.name, unless: method(:export_scope?)
end
