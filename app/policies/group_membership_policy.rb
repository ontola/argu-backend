class GroupMembershipPolicy < RestrictivePolicy
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
    def forum_policy
      Pundit.policy(context, record.try(:forum) || record.commentable.forum || context.context_model)
    end

    def profile_in_group?
      actor && (record.forum.groups & actor.groups).present?
    end

    delegate :is_manager?, to: :forum_policy
  end
  include Roles

  def permitted_attributes
    attributes = super
    attributes
  end

  def destroy?
    Pundit.policy(context, record.group).remove_member?(record) || super
  end

end
