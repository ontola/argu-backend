# frozen_string_literal: true
class ConversionPolicy < EdgeTreePolicy
  include ForumPolicy::ForumRoles

  class Scope < RestrictivePolicy::Scope
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
    attributes.concat %i(klass)
    attributes
  end

  def create?
    rule is_manager?, is_owner?, super
  end

  def new?
    rule is_manager?, is_owner?, super
  end

  private

  def forum_policy
    Pundit.policy(context, record.edge.owner.forum)
  end
end
