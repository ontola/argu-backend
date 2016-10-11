# frozen_string_literal: true
class CommentPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

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

  def permitted_attributes
    attributes = super
    attributes.concat %i(body parent_id) if create?
    attributes
  end

  def create?
    assert_siblings! if record.try(:parent_id).present?
    rule is_open?, is_member?, super
  end

  def destroy?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def edit?
    update?
  end

  def index?
    rule is_open?, has_access_token?, is_member?, is_manager?, is_owner?
  end

  def new?
    rule is_open?, create?
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
    Pundit.policy(context, context.forum)
  end
end
