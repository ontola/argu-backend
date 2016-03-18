class BlogPostPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @memberships = @profile.memberships if @profile
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      if context.forum.present?
        scope.where(forum_id: context.forum.id)
      end
    end
  end

  def permitted_attributes
    attributes = super
    attributes << %i(title content blog_postable published_at trashed_at) if create?
    attributes
  end

  def create?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def destroy?
    rule is_manager?, is_owner?, super
  end

  def edit?
    rule update?
  end

  def new?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def show?
    if record.is_published? && !record.is_trashed?
      rule parent_policy.show?
    else
      rule is_moderator?, is_manager?, is_owner?, super
    end
  end

  def trash?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def update?
    rule is_creator?, is_manager?, is_owner?, super
  end

  private

  def parent_policy
    Pundit.policy(context, record.blog_postable)
  end
end
