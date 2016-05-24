class OpinionPolicy < RestrictivePolicy
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
      scope.where(forum_id: context.forum.id) if context.forum.present?
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(body opinion_arguments_ids) if create?
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

  def untrash?
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
