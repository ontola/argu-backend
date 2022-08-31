# frozen_string_literal: true

class UserSerializer < RecordSerializer
  extend LanguageHelper
  extend URITemplateHelper

  def self.service_or_self?(object, opts)
    opts[:scope]&.service_scope? || self?(object, opts)
  end

  def self.self?(object, opts)
    object == opts[:scope]&.user
  end

  attribute :accept_terms, predicate: NS.argu[:acceptTerms], datatype: NS.xsd.boolean
  attribute :accepted_terms, predicate: NS.argu[:acceptedTerms], datatype: NS.xsd.boolean
  attribute :name_with_fallback, predicate: NS.schema.name
  attribute :display_name, predicate: NS.argu[:name]
  attribute :about, predicate: NS.schema.description
  attribute :finished_intro, predicate: NS.argu[:introFinished]
  attribute :show_feed, predicate: NS.argu[:votesPublic]
  attribute :is_public, predicate: NS.argu[:public]
  attribute :group_ids, predicate: NS.org[:organization] do |object|
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

  has_many :email_addresses, predicate: NS.argu[:emails], if: method(:service_or_self?)
  attribute :email, predicate: NS.schema.email, if: method(:service_or_self?)
  attribute :has_analytics, predicate: NS.argu[:hasAnalytics], if: method(:self?)
  attribute :password, predicate: NS.ontola[:password], datatype: NS.ontola['datatype/password'], if: method(:never)
  attribute :password_confirmation,
            predicate: NS.ontola[:passwordConfirmation],
            datatype: NS.ontola['datatype/password'],
            if: method(:never)
  attribute :current_password,
            predicate: NS.argu[:currentPassword],
            datatype: NS.ontola['datatype/password'],
            if: method(:never)
  attribute :redirect_url, predicate: NS.ontola[:redirectUrl], datatype: NS.xsd.string

  enum :destroy_strategy,
       predicate: NS.argu[:destroyStrategy],
       datatype: NS.xsd.string
  enum :reactions_email,
       predicate: NS.argu[:reactionsEmails],
       if: method(:self?),
       type: NS.schema.Thing,
       options: {
         never_reactions_email: {exact_match: NS.argu[:never]},
         weekly_reactions_email: {exact_match: NS.argu[:weekly]},
         daily_reactions_email: {exact_match: NS.argu[:daily]},
         direct_reactions_email: {exact_match: NS.argu[:direct]}
       }
  enum :news_email,
       predicate: NS.argu[:newsEmails],
       if: method(:self?),
       type: NS.schema.Thing,
       options: {
         never_news_email: {exact_match: NS.argu[:never]},
         weekly_news_email: {exact_match: NS.argu[:weekly]},
         daily_news_email: {exact_match: NS.argu[:daily]},
         direct_news_email: {exact_match: NS.argu[:direct]}
       }
  enum :language,
       type: NS.schema.Language,
       options: available_locales,
       predicate: NS.schema.language,
       if: method(:service_or_self?)
  enum :time_zone,
       type: NS.schema.Thing,
       predicate: NS.time[:timeZone],
       if: method(:service_or_self?),
       options: Hash[
         ActiveSupport::TimeZone.all.uniq(&:tzinfo).map do |value|
           id = value.tzinfo.name.gsub(%r{Etc/([A-Z]+)}, 'UTC')
           [value.tzinfo.name, {close_match: NS.dbpedia[id], label: value.to_s}]
         end
       ]
end
