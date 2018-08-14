# frozen_string_literal: true

class UserSerializer < RecordSerializer
  include ProfilePhotoable::Serializer

  def service_or_self?
    service_scope? || self
  end

  def self?
    object == scope&.user
  end

  has_one :profile, predicate: NS::ARGU[:profile]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]

  has_many :email_addresses, predicate: NS::ARGU[:emails], if: :service_or_self?
  attribute :language, predicate: NS::SCHEMA[:language], if: :service_or_self?
  attribute :time_zone, predicate: NS::TIME[:timeZone], if: :service_or_self?
  attribute :email, predicate: NS::SCHEMA[:email], if: :service_or_self?

  has_one :home_placement, predicate: NS::SCHEMA[:homeLocation], if: :self?
  attribute :has_analytics, predicate: NS::ARGU[:hasAnalytics], if: :self?
  attribute :birth_year, predicate: NS::DBO[:birthYear], datatype: NS::XSD[:gYear], if: :self?
  attribute :news_email, predicate: NS::ARGU[:newsEmails], if: :self?
  attribute :reactions_email, predicate: NS::ARGU[:reactionsEmails], if: :self?

  attribute :password, predicate: NS::ARGU[:password], datatype: NS::XSD[:string], only: false
  attribute :password_confirmation, predicate: NS::ARGU[:passwordConfirmation], datatype: NS::XSD[:string], only: false
  attribute :current_password, predicate: NS::ARGU[:currentPassword], datatype: NS::XSD[:string], only: false

  with_collection :vote_matches, predicate: NS::ARGU[:voteMatches]

  def about
    object.profile.about
  end

  def birth_year
    object.birthday&.year
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
end
