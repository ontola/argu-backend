# frozen_string_literal: true
class CommentPolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(body parent_id) if create?
    attributes
  end

  def create?
    return if record.edge.parent.owner_type == 'Argument' && record.edge.parent.owner.motion.closed?
    assert_siblings! if record.try(:parent_id).present?
    rule is_member?, super
  end

  def destroy?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def report?
    rule is_member?, is_manager?, staff?
  end

  def show?
    rule forum_policy.show?, super
  end

  def trash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def untrash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def update?
    rule is_creator?
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record.commentable.forum)
  end

  private

  def assert_siblings!
    assert! record.commentable == record.parent.commentable, :siblings?
  end

  def forum_policy
    Pundit.policy(context, context_forum)
  end
end
