# frozen_string_literal: true

class RestrictivePolicy
  include LinkedRails::Policy
  include Policies::AttributeConditions

  class Scope
    attr_reader :context, :user, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context, allow_nil: true
    delegate :profile, to: :context, allow_nil: true
    delegate :managed_profile_ids, to: :context, allow_nil: true
    delegate :export_scope?, :service_scope?, :system_scope?,
             to: :scope,
             allow_nil: true

    def resolve
      staff? ? scope : scope.none
    end

    def staff?
      user.is_staff?
    end
  end

  def feed?
    false
  end

  def staff?
    user.is_staff?
  end

  def service?
    @service ||= context.doorkeeper_scopes&.include? 'service'
  end

  delegate :user, :profile, :managed_profile_ids, :session_id, to: :context
  attr_reader :context, :record, :message

  def initialize(context, record)
    @context = context
    @record = record
    super()
  end

  def create?
    staff?
  end

  def new?
    create?
  end

  def destroy?
    staff?
  end

  # Used when an item displays nested content, therefore this should use the heaviest restrictions
  def show?
    staff? || service?
  end

  def update?
    staff?
  end

  def edit?
    update?
  end

  def scope
    Pundit.policy_scope!(context, record.class)
  end

  # Make sure that a tab param is actually accounted for
  # @return [String] The tab if it is considered valid
  def verify_tab(tab)
    tab ||= default_tab
    valid = permitted_tabs.include?(tab.to_sym)
    assert! valid, "#{tab}?"
    valid ? tab : default_tab
  end

  def default_tab
    'general'
  end

  def has_grant_set?(grant_set)
    user.profile.groups
      .joins(grants: :grant_set)
      .where(grants: {edge: ActsAsTenant.current_tenant})
      .pluck('grant_sets.title')
      .include?(grant_set.to_s)
  end

  private

  def add_array_attributes(array, *attrs)
    array.concat(attrs)
    array.concat(attrs.map { |attr| {attr => []} })
  end

  def assert!(assertion, query = nil)
    raise Argu::Errors::Forbidden.new(record: record, query: query) unless assertion
  end

  def cache_action(action, val)
    user_context.cache_key(record.identifier, action, val)
  end

  def check_action(action)
    return nil if record.try(:id).blank?

    user_context.check_key(record.identifier, action)
  end

  def current_session?
    record.session_id == session_id
  end

  def forbid_with_message(message)
    @message = message
    false
  end

  def new_record?
    record.is_a?(Class) || record.new_record?
  end

  def sanitize_attribute(attr)
    aliases = record&.class&.try(:attribute_aliases)&.select { |_k, v| attr.to_s == v }&.keys&.map(&:to_sym)
    [attr] + (aliases || [])
  end

  def user_context
    @context
  end
end
