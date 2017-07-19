# frozen_string_literal: true
class VoteMatchPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat [:name, voteables: [:resource_type, :iri], vote_comparables: [:resource_type, :iri]]
    attributes
  end

  def show?
    true
  end

  def create?
    true
  end

  def is_creator?
    creator if record.creator.present? && record.creator == actor
  end

  private

  def destroy_roles
    [is_creator? || super]
  end

  def update_roles
    [is_creator? || super]
  end
end
