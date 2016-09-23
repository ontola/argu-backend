# frozen_string_literal: true
class ArgumentPolicy < EdgeTreePolicy
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
    attributes.concat %i(title content pro) if create?
    attributes
  end

  def create?
    return create_expired? if has_expired_ancestors?
    rule is_member?, is_manager?, is_owner?, super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, is_owner?, super
  end

  def trash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def untrash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def destroy?
    creator = 1.hour.ago <= record.created_at ? is_creator? : nil
    rule creator, is_manager?, is_owner?, super
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_member?, is_manager?, is_owner?, super
  end
end
