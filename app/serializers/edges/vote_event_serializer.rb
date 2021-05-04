# frozen_string_literal: true

class VoteEventSerializer < EdgeSerializer
  attribute :expires_at, predicate: NS::SCHEMA[:endDate]
  attribute :option_counts, unless: method(:export_scope?) do |object|
    {
      yes: object.children_count(:votes_pro),
      neutral: object.children_count(:votes_neutral),
      no: object.children_count(:votes_con)
    }
  end
  attribute :pro_count
  attribute :con_count
  attribute :neutral_count

  count_attribute :votes_pro
  count_attribute :votes_con
  count_attribute :votes_neutral
end
