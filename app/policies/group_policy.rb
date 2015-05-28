class GroupPolicy < RestrictivePolicy
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

  module Roles
    delegate :is_manager?, to: :forum_policy
  end
  include Roles

  def permitted_attributes
    attributes = super
    attributes << [:name, :name_singular, :icon, :max_responses_per_member] if create?
    attributes << [:id] if staff?
    attributes
  end

  def new?
    create?
  end

  def create?
    rule is_manager?, super
  end

  def update?
    rule is_manager?, super
  end

  def edit?
    update?
  end

  def remove_member?(member)
    rule is_manager?, super
  end
end
