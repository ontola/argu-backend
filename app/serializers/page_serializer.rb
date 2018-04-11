# frozen_string_literal: true

class PageSerializer < RecordSerializer
  include Menuable::Serializer
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :base_color, predicate: NS::ARGU[:baseColor]
  include_menus

  has_one :profile_photo, predicate: NS::SCHEMA[:image] do
    object.profile.default_profile_photo
  end
  with_collection :vote_matches, predicate: NS::ARGU[:voteMatches]

  def about
    object.profile.about
  end

  def vote_match_collection
    object.vote_match_collection(user_context: scope)
  end
end
