# frozen_string_literal: true

class VoteMatchPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat [:name, voteables: %i[item_type item_iri], vote_comparables: %i[item_type item_iri]]
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
    record.publisher_id.present? && record.publisher_id == user.id
  end
end
