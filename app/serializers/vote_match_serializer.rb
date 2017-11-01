# frozen_string_literal: true

class VoteMatchSerializer < RecordSerializer
  attribute :name, predicate: RDF::SCHEMA[:name]
  attribute :text, predicate: RDF::SCHEMA[:text]

  has_many :voteables, predicate: RDF::ARGU[:motions]
  has_many :vote_comparables, predicate: RDF::ARGU[:profiles]

  has_one :creator, predicate: RDF::SCHEMA[:creator] do
    object.creator.profileable
  end
  has_one :vote_compare_result, predicate: RDF::ARGU[:voteCompareResult] do
    {
      id: "https://#{Rails.application.config.host_name}/compare/votes?vote_match=#{object.id}",
      type: RDF::ARGU[:voteCompareResults]
    }
  end
end
