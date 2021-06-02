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

  attribute :accept_terms, predicate: NS::ARGU[:acceptTerms], datatype: NS::XSD[:boolean]
  attribute :accepted_terms, predicate: NS::ARGU[:acceptedTerms], datatype: NS::XSD[:boolean]
  attribute :name_with_fallback, predicate: NS::SCHEMA[:name]
  attribute :display_name, predicate: NS::ARGU[:name]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :finished_intro, predicate: NS::ARGU[:introFinished]
  attribute :url,
            predicate: NS::ARGU[:shortname],
            datatype: NS::XSD[:string],
            if: method(:service_or_self?), &:url
  attribute :show_feed, predicate: NS::ARGU[:votesPublic]
  attribute :is_public, predicate: NS::ARGU[:public]
  attribute :group_ids, predicate: NS::ORG[:organization] do |object|
    if ActsAsTenant.current_tenant && object.profile
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
  attribute :password, predicate: NS::ONTOLA[:password], datatype: NS::ONTOLA['datatype/password'], if: method(:never)
  attribute :password_confirmation,
            predicate: NS::ONTOLA[:passwordConfirmation],
            datatype: NS::ONTOLA['datatype/password'],
            if: method(:never)
  attribute :current_password,
            predicate: NS::ARGU[:currentPassword],
            datatype: NS::ONTOLA['datatype/password'],
            if: method(:never)
  attribute :redirect_url, predicate: NS::ONTOLA[:redirectUrl], datatype: NS::XSD[:string]
  statements :same_as_canonical

  enum :destroy_strategy,
       predicate: NS::ARGU[:destroyStrategy],
       datatype: NS::XSD[:string]
  enum :reactions_email,
       predicate: NS::ARGU[:reactionsEmails],
       if: method(:self?),
       type: NS::SCHEMA[:Thing],
       options: {
         never_reactions_email: {exact_match: NS::ARGU[:never]},
         weekly_reactions_email: {exact_match: NS::ARGU[:weekly]},
         daily_reactions_email: {exact_match: NS::ARGU[:daily]},
         direct_reactions_email: {exact_match: NS::ARGU[:direct]}
       }
  enum :news_email,
       predicate: NS::ARGU[:newsEmails],
       if: method(:self?),
       type: NS::SCHEMA[:Thing],
       options: {
         never_news_email: {exact_match: NS::ARGU[:never]},
         weekly_news_email: {exact_match: NS::ARGU[:weekly]},
         daily_news_email: {exact_match: NS::ARGU[:daily]},
         direct_news_email: {exact_match: NS::ARGU[:direct]}
       }
  enum :decisions_email,
       type: NS::SCHEMA[:Thing],
       predicate: NS::ARGU[:decisionsEmails],
       if: method(:self?),
       options: {
         never_decisions_email: {exact_match: NS::ARGU[:never]},
         weekly_decisions_email: {exact_match: NS::ARGU[:weekly]},
         daily_decisions_email: {exact_match: NS::ARGU[:daily]},
         direct_decisions_email: {exact_match: NS::ARGU[:direct]}
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
           id = value.tzinfo.name.gsub(%r{Etc\/([A-Z]+)}, 'UTC')
           [value.tzinfo.name, {close_match: NS::DBPEDIA[id], label: value.to_s}]
         end
       ]

  def self.same_as_canonical(object, _params)
    return [] if object.url.nil?

    [
      [object.canonical_iri, NS::OWL.sameAs, object.iri]
    ]
  end
end
