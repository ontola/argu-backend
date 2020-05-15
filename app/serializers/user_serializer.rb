# frozen_string_literal: true

class UserSerializer < RecordSerializer
  extend LanguageHelper
  extend UriTemplateHelper

  def self.service_or_self?(object, opts)
    opts[:scope]&.service_scope? || self?(object, opts)
  end

  def self.self?(object, opts)
    object == opts[:scope]&.user
  end

  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :name, predicate: NS::FOAF[:name]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :url,
            predicate: NS::ARGU[:shortname],
            datatype: NS::XSD[:string],
            if: method(:service_or_self?), &:url
  attribute :first_name, predicate: NS::SCHEMA[:givenName], datatype: NS::XSD[:string], if: method(:service_or_self?)
  attribute :last_name, predicate: NS::SCHEMA[:familyName], datatype: NS::XSD[:string], if: method(:service_or_self?)
  attribute :hide_last_name, predicate: NS::ARGU[:hideLastName], if: method(:service_or_self?)
  attribute :show_feed, predicate: NS::ARGU[:votesPublic]
  attribute :is_public, predicate: NS::ARGU[:public]
  attribute :group_ids, predicate: NS::ORG[:organization] do |object|
    if ActsAsTenant.current_tenant
      Group
        .joins(group_memberships: :member)
        .where('groups.root_id = ? OR groups.id = ?', ActsAsTenant.current_tenant.uuid, Group::STAFF_ID)
        .where(profiles: {id: object.profile.id})
        .pluck(:id)
        .map do |group_id|
        iri_from_template(:groups_iri, id: group_id)
      end
    end
  end

  has_many :email_addresses, predicate: NS::ARGU[:emails], if: method(:service_or_self?)
  attribute :email, predicate: NS::SCHEMA[:email], if: method(:service_or_self?)
  attribute :has_analytics, predicate: NS::ARGU[:hasAnalytics], if: method(:self?)
  attribute :password, predicate: NS::ARGU[:password], datatype: NS::ONTOLA['datatype/password'], if: method(:never)
  attribute :password_confirmation,
            predicate: NS::ARGU[:passwordConfirmation],
            datatype: NS::ONTOLA['datatype/password'],
            if: method(:never)
  attribute :current_password,
            predicate: NS::ARGU[:currentPassword],
            datatype: NS::ONTOLA['datatype/password'],
            if: method(:never)

  enum :reactions_email,
       predicate: NS::ARGU[:reactionsEmails],
       if: method(:self?),
       type: NS::SCHEMA[:Thing],
       options: {
         never_reactions_email: {iri: NS::ARGU[:never]},
         weekly_reactions_email: {iri: NS::ARGU[:weekly]},
         daily_reactions_email: {iri: NS::ARGU[:daily]},
         direct_reactions_email: {iri: NS::ARGU[:direct]}
       }
  enum :news_email,
       predicate: NS::ARGU[:newsEmails],
       if: method(:self?),
       type: NS::SCHEMA[:Thing],
       options: {
         never_news_email: {iri: NS::ARGU[:never]},
         weekly_news_email: {iri: NS::ARGU[:weekly]},
         daily_news_email: {iri: NS::ARGU[:daily]},
         direct_news_email: {iri: NS::ARGU[:direct]}
       }
  enum :decisions_email,
       type: NS::SCHEMA[:Thing],
       predicate: NS::ARGU[:decisionsEmails],
       if: method(:self?),
       options: {
         never_decisions_email: {iri: NS::ARGU[:never]},
         weekly_decisions_email: {iri: NS::ARGU[:weekly]},
         daily_decisions_email: {iri: NS::ARGU[:daily]},
         direct_decisions_email: {iri: NS::ARGU[:direct]}
       }
  enum :language,
       type: NS::SCHEMA[:Language],
       options: available_locales,
       predicate: NS::SCHEMA[:language],
       if: method(:service_or_self?)
  enum :time_zone,
       type: NS::SCHEMA[:Thing],
       predicate: NS::TIME[:timeZone],
       if: method(:service_or_self?),
       options: Hash[
         ActiveSupport::TimeZone.all.uniq(&:tzinfo).map do |value|
           [value.name.to_sym, {iri: NS::DBPEDIA[value.tzinfo.name.gsub(%r{Etc\/([A-Z]+)}, 'UTC')], label: value.to_s}]
         end
       ]
end
