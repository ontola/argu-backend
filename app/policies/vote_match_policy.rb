# frozen_string_literal: true
class VoteMatchPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat [:name, voteables: [:resource_type, :iri], comparables: [:resource_type, :iri]]
    attributes
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    is_creator? || super
  end

  def update?
    is_creator? || super
  end

  def is_creator?
    creator if record.creator.present? && record.creator == actor
  end
end
