# frozen_string_literal: true
class GrantPolicy < EdgeTreePolicy
  class Scope < Scope
    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(group_id edge_id role)
    attributes
  end

  def create?
    rule is_manager?, super
  end

  def destroy?
    return nil if record.group_id == -1
    rule is_manager?, super
  end
end
