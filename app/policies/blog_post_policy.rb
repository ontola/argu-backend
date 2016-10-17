# frozen_string_literal: true
class BlogPostPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      super.published_or_published_by(user&.id)
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title content blog_postable trashed_at happened_at) if create?
    publication_attributes = %i(id published_at publish_type)
    attributes.append(argu_publication_attributes: publication_attributes)
    happening_attributes = %i(id happened_at)
    attributes.append(happening_attributes: happening_attributes)
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
