# frozen_string_literal: true

class PageSerializer < RecordSerializer
  include Menuable::Serializer
  include ProfilePhotoable::Serializer

  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :base_color, predicate: NS::ARGU[:baseColor]
  include_menus

  with_collection :vote_matches, predicate: NS::ARGU[:voteMatches]

  def about
    object.profile.about
  end

  def default_profile_photo
    object.profile.default_profile_photo
  end
end
