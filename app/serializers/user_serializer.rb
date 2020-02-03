# frozen_string_literal: true

class UserSerializer < RecordSerializer # rubocop:disable Metrics/ClassLength
  include ProfilePhotoable::Serializer
  include CoverPhotoable::Serializer
  include UriTemplateHelper
  extend LanguageHelper

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
  attribute :hide_last_name, predicate: NS::ARGU[:hideLastName], if: :service_or_self?
  attribute :are_votes_public, predicate: NS::ARGU[:votesPublic]
  attribute :is_public, predicate: NS::ARGU[:public]
  attribute :group_ids, predicate: NS::ORG[:organization]

  has_many :email_addresses, predicate: NS::ARGU[:emails], if: :service_or_self?
  attribute :language, predicate: NS::SCHEMA[:language], if: :service_or_self?
  attribute :time_zone, predicate: NS::TIME[:timeZone], if: :service_or_self?
  attribute :email, predicate: NS::SCHEMA[:email], if: :service_or_self?

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
       type: NS::SCHEMA[:Language],
       options: available_locales
  enum :time_zone,
       type: NS::SCHEMA[:Thing],
       options: Hash[
         ActiveSupport::TimeZone.all.uniq(&:tzinfo).map do |value|
           [value.name.to_sym, {iri: NS::DBPEDIA[value.tzinfo.name.gsub(%r{Etc\/([A-Z]+)}, 'UTC')], label: value.to_s}]
         end
       ]

  def about
    object.profile.about
  end

  def are_votes_public
    object.profile.are_votes_public
  end

  def birth_year
    object.birthday&.year
  end

  def default_cover_photo
    object.profile.default_cover_photo
  end

  def default_profile_photo
    object.profile.default_profile_photo
  end

  def group_ids
    return unless ActsAsTenant.current_tenant

    Group
      .joins(group_memberships: :member)
      .where('groups.root_id = ? OR groups.id = ?', ActsAsTenant.current_tenant.uuid, Group::STAFF_ID)
      .where(profiles: {id: object.profile.id})
      .pluck(:id)
      .map do |group_id|
      iri_from_template(:groups_iri, id: group_id)
    end
  end

  def is_public
    object.profile.is_public
  end

  def object
    super.is_a?(Profile) ? super.profileable : super
  end

  def shortname
    object.url
  end
end
