# frozen_string_literal: true

class PageSerializer < RecordSerializer
  include ProfilePhotoable::Serializer

  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :base_color, predicate: NS::ARGU[:baseColor]

  with_collection :vote_matches, predicate: NS::ARGU[:voteMatches]
  with_collection :forums, predicate: NS::ARGU[:forums]

  def about
    object.profile.about
  end

  def default_profile_photo
    object.profile.default_profile_photo
  end
end
