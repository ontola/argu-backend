# frozen_string_literal: true

class UserSerializer < RecordSerializer
  include ProfilePhotoable::Serializer

  def service_or_self?
    service_scope? || object == scope&.user
  end

  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :url
  attribute :language, predicate: NS::SCHEMA[:language], if: :service_scope?
  attribute :email, predicate: NS::SCHEMA[:email], if: :service_or_self?
  has_many :email_addresses, predicate: NS::ARGU[:emails], if: :service_or_self?

  with_collection :vote_matches, predicate: NS::ARGU[:voteMatches]

  def about
    object.profile.about
  end

  def default_profile_photo
    object.profile.default_profile_photo
  end

  def object
    super.is_a?(Profile) ? super.profileable : super
  end

  def shortname
    object.url
  end

  def type
    NS::SCHEMA[:Person]
  end
end
