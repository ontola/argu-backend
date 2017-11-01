# frozen_string_literal: true

class PageSerializer < RecordSerializer
  include Menuable::Serializer
  attribute :about, predicate: RDF::SCHEMA[:description]
  include_menus

  has_one :profile_photo, predicate: RDF::SCHEMA[:image] do
    object.profile.default_profile_photo
  end
  has_one :vote_match_collection, predicate: RDF::ARGU[:voteMatches]

  def about
    object.profile.about
  end

  def vote_match_collection
    object.vote_match_collection(user_context: scope)
  end
end
