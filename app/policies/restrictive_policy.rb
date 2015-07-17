class RestrictivePolicy
  include AccessTokenHelper, UsersHelper
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
    def member
      3
    end

    def creator
      4
    end

    def owner
      6
    end

    def staff
      10
    end


    def is_creator?
      creator if record.creator == actor
    end

    def is_member?
      member if user && user.profile.member_of?(record.forum || record.forum_id)
    end

    def staff?
      staff if user && user.profile.has_role?(:staff)
    end

    def forum_policy
      Pundit.policy(context, record.try(:forum) || context.context_model)
    end
  end
  include Roles

  def initialize(context, record)
    @context = context
    @record = record

    # This can't only check for access to a record when the platform is public,
    # since it would require the user to be logged in to see anything (requirements
    # decrease security here, so it is absolutely necessary to authorize properly
    # in all child classes)
    unless platform_open? || within_user_cap? || has_access_to_record?
      raise Argu::NotLoggedInError.new(nil, record), 'must be logged in'
    end
  end

  delegate :user, to: :context
  delegate :actor, to: :context
  delegate :session, to: :context

  def permitted_attributes
    attributes = [:lock_version]
    attributes << :shortname if shortname?
    attributes << :is_trashed if trash?
    attributes
  end


  def self.assert!(assertion)
    raise Pundit::NotAuthorizedError unless assertion
  end
  delegate :assert!, to: :class

  def change_owner?
    rule is_owner?, staff?
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

  def follow?
    is_member? || staff?
  end

  def index?
    staff?
  end

  def logged_in?
    user.present?
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

  # Move items between forums or converting items
  def move?
    staff?
  end

  def trash?
    staff?
  end

  def update?
    staff?
  end

  def vote?
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

end

