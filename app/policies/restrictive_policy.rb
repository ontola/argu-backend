# frozen_string_literal: true
require 'exception_to_the_rule'

class RestrictivePolicy
  include TuplesHelper
  prepend ExceptionToTheRule

  attr_reader :context, :record

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
      user.profile.has_role?(:staff)
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
      staff if user.profile.has_role?(:staff)
    end

    def service
      9
    end

    def service?
      service if context.doorkeeper_scopes&.include? 'service'
    end
  end
  include Roles

  def initialize(context, record)
    @context = context
    @record = record
  end

  def user_context
    @context
  end

  def cache_level(level, val)
    user_context.cache_key(record.identifier, level, val)
  end

  def check_level(level)
    return nil if record.try(:id).blank?
    l = user_context.check_key(record.identifier, level)
    # puts "============LEVEL HIT #{l}=====================" unless l.nil?
    l
  end

  def cache_action(action, val)
    user_context.cache_key(record.identifier, action, val)
  end

  def check_action(action)
    return nil if record.try(:id).blank?
    user_context.check_key(record.identifier, action)
  end

  delegate :user, to: :context
  delegate :actor, to: :context

  def permitted_attributes
    attributes = [:lock_version]
    attributes.append(shortname_attributes: %i(shortname id)) if shortname?
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

  def assert!(assertion, query = nil)
    raise Argu::NotAuthorizedError.new(record: record, query: query) unless assertion
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  def edit?
    update?
  end

  def feed?
    rule staff?
  end

  def logged_in?
    !user.guest?
  end

  def new?
    create?
  end

  def new_record?
    record.is_a?(Class) || record.new_record?
  end

  # Used when an item displays nested content, therefore this should use the heaviest restrictions
  def show?
    staff? || service?
  end

  def statistics?
    staff?
  end

  # Used when items won't include nested content, this is a less restrictive version of show?
  def list?
    staff?
  end

  def update?
    staff?
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
    assert! permitted_tabs.include?(tab.to_sym), "#{tab}?"
    tab
  end

  private

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

  def default_tab
    'general'
  end
end
