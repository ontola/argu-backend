# frozen_string_literal: true

class UserSerializer < RecordSerializer
  def service_or_self?
    service_scope? || object == scope&.user
  end

  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :url
  attribute :language, predicate: NS::SCHEMA[:language], if: :service_scope?
  attribute :email, predicate: NS::SCHEMA[:email], if: :service_or_self?
  has_many :email_addresses, predicate: NS::ARGU[:emails], if: :service_or_self?

  has_one :profile_photo, predicate: NS::SCHEMA[:image] do
    object.profile.default_profile_photo
  end

  has_one :vote_match_collection, predicate: NS::ARGU[:voteMatches]

  def vote_match_collection
    object.vote_match_collection(user_context: scope)
  end

  def about
    object.profile.about
  end

  def shortname
    object.url
  end

  def type
    NS::SCHEMA[:Person]
  end
end
