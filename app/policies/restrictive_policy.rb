# frozen_string_literal: true
require 'exception_to_the_rule'

class RestrictivePolicy
  include AccessTokenHelper, TuplesHelper
  prepend ExceptionToTheRule

  attr_reader :context, :record

  class Scope
    include AccessTokenHelper
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
  end
  include Roles

  def initialize(context, record)
    @context = context
    @record = record
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
    staff?
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

  # Whether the User is logged in, or has an AccessToken for `record`
  # Note: Not to be confused with policy(record).show? which validates
  #       access for a specific item
  def has_access_to_record?
    user || has_access_token_access_to(record, user)
  end

  def scope
    Pundit.policy_scope!(context, record.class)
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
end
