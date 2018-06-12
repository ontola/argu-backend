# frozen_string_literal: true

class RestrictivePolicy
  include TuplesHelper

  class Scope
    attr_reader :context, :user, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :actor, to: :context
    delegate :export_scope?, :service_scope?, :system_scope?,
             to: :scope,
             allow_nil: true

    def resolve
      scope if staff?
    end

    def staff?
      user.is_staff?
    end
  end

  def staff?
    user.is_staff?
  end

  def service?
    @service ||= context.doorkeeper_scopes&.include? 'service'
  end

  delegate :user, to: :context
  delegate :actor, to: :context
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record
  end

  def permitted_attribute_names
    attributes = []
    attributes.append(shortname_attributes: %i[shortname id]) if shortname?
    attributes
  end

  def permitted_attributes
    names = permitted_attribute_names
    aliases =
      record&.class&.try(:attribute_aliases)&.select { |_k, v| names.map(&:to_s).include?(v) }&.keys&.map(&:to_sym)
    names + (aliases || [])
  end

  # @param parent_key [String, Symbol] Parent key of the wanted subset
  # @param second_key [String, Symbol] Key for further digging
  # @return [Array] Allowed attributes, nested under a parent key
  def permitted_nested_attributes(parent_key, second_key = nil)
    attributes = (permitted_attributes.find { |a| a.is_a?(Hash) && a[parent_key] } || {})[parent_key]
    unless second_key.nil?
      attributes = attributes.detect { |value| value.is_a?(Hash) && value.keys == [second_key] }[second_key]
    end
    attributes
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

  def delete?
    destroy?
  end

  def feed?
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

  def create_child?(_raw_klass)
    false
  end

  def index_children?(_raw_klass)
    false
  end

  # Can the current user change the item shortname?
  def shortname?
    new_record?
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

  private

  def assert!(assertion, query = nil)
    raise Argu::Errors::Forbidden.new(record: record, query: query) unless assertion
  end

  def append_default_photo_params(attributes)
    attributes.append(
      default_cover_photo_attributes: Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
    )
    attributes.append(
      default_profile_photo_attributes: Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
    )
  end

  def append_attachment_params(attributes)
    attributes.append(
      attachments_attributes: Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
    )
  end

  def cache_action(action, val)
    user_context.cache_key(record.identifier, action, val)
  end

  def check_action(action)
    return nil if record.try(:id).blank?
    user_context.check_key(record.identifier, action)
  end

  def new_record?
    record.is_a?(Class) || record.new_record?
  end

  def user_context
    @context
  end
end
