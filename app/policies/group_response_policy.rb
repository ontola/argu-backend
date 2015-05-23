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
    delegate :is_manager?, to: :forum_policy

    # @note: This is prone to race conditions, but since a group_responses isn't a vote, it can be considered trivial.
    def limit_reached?
      if record.group.max_responses_per_member == -1
        false
      else
        record.motion.responses_from(actor) >= record.group.max_responses_per_member
      end
    end

    def profile_in_group?
      actor && actor.groups.include?(record.group).present?
    end

    def is_creator?
      record.creator == actor
    end
  end
  include Roles

  def permitted_attributes
    attributes = super
    attributes << [:text, :side] if create?
    attributes << [:text, :side] if update?
    attributes << [:id] if staff?
    attributes
  end

  def new?
    create?
  end

  def create?
    profile_in_group? && !limit_reached?
  end

  def update?
    profile_in_group? && record.profile == actor
  end

  def edit?
    update?
  end

  def destroy?
    profile_in_group? && is_creator? || super
  end
end
