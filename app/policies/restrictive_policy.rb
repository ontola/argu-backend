# frozen_string_literal: true

require 'exception_to_the_rule'

class RestrictivePolicy
  include TuplesHelper
  prepend ExceptionToTheRule

  class Scope
    attr_reader :context, :user, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :actor, to: :context

    def resolve
      scope if staff?
    end

    def staff?
      user.is_staff?
    end
  end

  module Roles
    def creator
      4
    end

    def staff
      10
    end

    def staff?
      staff if user.is_staff?
    end

    def service
      9
    end

    def service?
      service if context.doorkeeper_scopes&.include? 'service'
    end
  end
  include Roles

  delegate :user, to: :context
  delegate :actor, to: :context
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record
  end

  def permitted_attributes
    attributes = [:lock_version]
    attributes.append(shortname_attributes: %i[shortname id]) if shortname?
    attributes
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
    rule staff?
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
    raise Argu::Errors::NotAuthorized.new(record: record, query: query) unless assertion
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
