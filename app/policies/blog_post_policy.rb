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
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title content trashed_at happened_at) if create?
    happening_attributes = %i(id happened_at)
    attributes.append(happening_attributes: happening_attributes)
    attributes
  end

  def create?
    assert_publish_type
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def destroy?
    rule is_manager?, is_owner?, super
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule parent_policy.show?
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
end
