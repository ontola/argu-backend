class RestrictivePolicy
  include AccessTokenHelper
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

    # Not an actual role, but reserved nevertheless
    def group_grant
      5
    end

    def moderator
      6
    end

    def owner
      8
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

    def is_moderator?
      c_model = record.try(:forum) || context.context_model
      if user.present? && c_model.present?
        # Stepups within the forum based if they apply to the user or one of its group memberships
        forum_stepups = c_model.stepups.where('user_id=? OR group_id=?', user.id, user.profile.groups.where(forum: c_model).pluck(:id))
        # Get the tuples of the entire parent chain
        cc = Context.new(record).map(&:polymorphic_tuple).compact
        # Match them against the set of stepups within the forum
        moderator if forum_stepups.where("(record_type, record_id) IN #{"(#{cc.map { |t| "('#{t[0]}', #{t[1]})" }.join(', ')})"}").presence
      end
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
  end

  delegate :user, to: :context
  delegate :actor, to: :context
  delegate :session, to: :context

  def permitted_attributes
    attributes = [:lock_version]
    attributes << :shortname if shortname?
    attributes << :is_trashed if !record.is_a?(Class) && trash?
    attributes
  end

  def assert!(assertion, query = nil)
    raise Pundit::NotAuthorizedError.new(record: record, query: query) unless assertion
  end

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

  protected
  def platform_open?
    context.opts[:platform_open]
  end

  def within_user_cap?
    context.opts[:within_user_cap]
  end

end

