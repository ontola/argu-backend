class GroupResponsePolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope
    end
  end

  module Roles
    delegate :is_manager?, :is_owner?, to: :forum_policy
    delegate :open, :access_token, :member, :manager, :owner, to: :forum_policy

    # @note: This is prone to race conditions, but since a group_responses isn't a vote, it can be considered trivial.
    def limit_reached?
      if record.group.max_responses_per_member == -1
        false
      else
        record.motion.responses_from(actor, record.group) >= record.group.max_responses_per_member
      end
    end

    def profile_in_group?
      member if actor && actor.groups.include?(record.group).present?
    end

    def is_creator?
      creator if record.creator == actor && profile_in_group?
    end
  end
  include Roles

  def permitted_attributes
    attributes = super
    attributes.concat %i(text side) if create?
    attributes.concat %i(text side) if update?
    attributes.append :id if staff?
    attributes
  end

  def show?
    if record.motion.project.present?
      rule Pundit.policy(context, record.motion.project).show?, super
    else
      rule forum_policy.show?, super
    end
  end

  def new?
    create?
  end

  def create?
    rule limit_reached? ? nil : profile_in_group?, super
  end

  def update?
    rule is_creator?, super
  end

  def edit?
    update?
  end

  def destroy?
    rule is_creator?, is_manager?, is_owner?, super
  end
end
