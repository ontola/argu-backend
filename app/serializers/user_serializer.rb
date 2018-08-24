# frozen_string_literal: true

class UserSerializer < RecordSerializer
  include ProfilePhotoable::Serializer

  def service_or_self?
    service_scope? || self?
  end

  def self?
    object == scope&.user
  end

  has_one :profile, predicate: NS::ARGU[:profile]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string], if: :service_or_self?
  attribute :first_name, predicate: NS::SCHEMA[:givenName], datatype: NS::XSD[:string], if: :service_or_self?
  attribute :last_name, predicate: NS::SCHEMA[:familyName], datatype: NS::XSD[:string], if: :service_or_self?

  has_many :email_addresses, predicate: NS::ARGU[:emails], if: :service_or_self?
  attribute :language, predicate: NS::SCHEMA[:language], if: :service_or_self?
  attribute :time_zone, predicate: NS::TIME[:timeZone], if: :service_or_self?
  attribute :email, predicate: NS::SCHEMA[:email], if: :service_or_self?

  has_one :home_placement, predicate: NS::SCHEMA[:homeLocation], if: :self?
  attribute :has_analytics, predicate: NS::ARGU[:hasAnalytics], if: :self?
  attribute :birth_year, predicate: NS::DBO[:birthYear], datatype: NS::XSD[:gYear], if: :self?
  attribute :news_email, predicate: NS::ARGU[:newsEmails], if: :self?
  attribute :reactions_email, predicate: NS::ARGU[:reactionsEmails], if: :self?

  attribute :password, predicate: NS::ARGU[:password], datatype: NS::ONTOLA['datatype/password'], if: :never
  attribute :password_confirmation,
            predicate: NS::ARGU[:passwordConfirmation],
            datatype: NS::ONTOLA['datatype/password'],
            if: :never
  attribute :current_password,
            predicate: NS::ARGU[:currentPassword],
            datatype: NS::ONTOLA['datatype/password'],
            if: :never

  enum :reactions_email,
       type: NS::SCHEMA[:Thing],
       options: {
         never_reactions_email: {iri: NS::ARGU[:never]},
         weekly_reactions_email: {iri: NS::ARGU[:weekly]},
         daily_reactions_email: {iri: NS::ARGU[:daily]},
         direct_reactions_email: {iri: NS::ARGU[:direct]}
       }
  enum :news_email,
       type: NS::SCHEMA[:Thing],
       options: {
         never_news_email: {iri: NS::ARGU[:never]},
         weekly_news_email: {iri: NS::ARGU[:weekly]},
         daily_news_email: {iri: NS::ARGU[:daily]},
         direct_news_email: {iri: NS::ARGU[:direct]}
       }
  enum :decisions_email,
       type: NS::SCHEMA[:Thing],
       options: {
         never_decisions_email: {iri: NS::ARGU[:never]},
         weekly_decisions_email: {iri: NS::ARGU[:weekly]},
         daily_decisions_email: {iri: NS::ARGU[:daily]},
         direct_decisions_email: {iri: NS::ARGU[:direct]}
       }
  enum :language,
       type: NS::SCHEMA[:Thing],
       options: Hash[
         I18n
           .available_locales
           .map { |l| [l.to_sym, {iri: NS::ARGU["locale/#{l}"], label: I18n.t(:language, locale: l)}] }
       ]
  enum :time_zone,
       type: NS::SCHEMA[:Thing],
       options: Hash[
         ActiveSupport::TimeZone.all.uniq(&:tzinfo).map do |value|
           [value.name.to_sym, {iri: NS::DBPEDIA[value.tzinfo.name.gsub(%r{Etc\/([A-Z]+)}, 'UTC')], label: value.to_s}]
         end
       ]

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
