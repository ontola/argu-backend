class CommentPolicy < RestrictivePolicy
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

    delegate :is_member?, :is_owner?, :is_manager?, to: :forum_policy
  end
  include Roles

  def create?
    record.commentable.forum.open? || is_member? || super
  end

  def destroy?
    user && record.profile_id == actor.id || is_owner? || super
  end

  def edit?
    update?
  end

  def new?
    record.forum.open? || create?
  end

  def report?
    true
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  def trash?
    is_creator? || is_manager? || is_owner? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record.commentable.forum)
  end

end
