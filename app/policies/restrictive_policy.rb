# frozen_string_literal: true
require 'exception_to_the_rule'

class RestrictivePolicy
  include AccessTokenHelper, TuplesHelper
  prepend ExceptionToTheRule

  attr_reader :context, :record

  class Scope
    include AccessTokenHelper
    attr_reader :context, :user, :scope, :session

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :actor, to: :context
    delegate :session, to: :context

    def resolve
      scope if staff?
    end

    def staff?
      user && user.profile.has_role?(:staff)
    end
  end

  module Roles
    def staff
      10
    end

    def staff?
      staff if user && user.profile.has_role?(:staff)
    end
  end
  include Roles

  def initialize(context, record)
    @context = context
    @record = record
  end

  delegate :user, to: :context
  delegate :actor, to: :context
  delegate :session, to: :context

  def permitted_attributes
    attributes = [:lock_version]
    attributes.append :shortname if shortname?
    attributes
  end

  # @param parent_key [String, Symbol] Parent key of the wanted subset
  # @return [Array] Allowed attributes, nested under a parent key
  def permitted_nested_attributes(parent_key)
    (permitted_attributes.find { |a| a.is_a?(Hash) && a[parent_key] } || {})[parent_key].flatten
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
    staff?
  end

  def index?
    staff?
  end

  def logged_in?
    user.present?
  end

  def new?
    staff?
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

  # Whether the user has access to Argu in general
  def has_access_to_platform?
    user || has_valid_token?
  end

  # Whether the User is logged in, or has an AccessToken for `record`
  # Note: Not to be confused with policy(record).show? which validates
  #       access for a specific item
  def has_access_to_record?
    user || has_access_token_access_to(record)
  end

  def scope
    Pundit.policy_scope!(context, record.class)
  end

  private

  def append_default_photo_params(attributes)
    attributes.append(default_cover_photo_attributes: Pundit.policy(context, Photo.new).permitted_attributes)
    attributes.append(default_profile_photo_attributes: Pundit.policy(context, Photo.new).permitted_attributes)
  end
end
