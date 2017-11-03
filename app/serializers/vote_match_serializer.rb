# frozen_string_literal: true

class VoteMatchSerializer < RecordSerializer
  attribute :name, predicate: NS::SCHEMA[:name]
  attribute :text, predicate: NS::SCHEMA[:text]

  has_many :voteables, predicate: NS::ARGU[:motions]
  has_many :vote_comparables, predicate: NS::ARGU[:profiles]

  has_one :creator, predicate: NS::SCHEMA[:creator] do
    object.creator.profileable
  end
  has_one :vote_compare_result, predicate: NS::ARGU[:voteCompareResult] do
    {
      id: "https://#{Rails.application.config.host_name}/compare/votes?vote_match=#{object.id}",
      type: NS::ARGU[:voteCompareResults]
    }
  end
end
