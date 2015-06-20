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

  def create?
    rule is_open?, is_member?, super
  end

  def destroy?
    rule is_creator?, is_owner?, super
  end

  def edit?
    update?
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

  def update?
    rule (is_member? && is_creator?), is_manager?, is_owner?, super
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record.commentable.forum)
  end

  private
  def forum_policy
    Pundit.policy(context, record.try(:forum) || record.commentable.forum || context.context_model)
  end
end
