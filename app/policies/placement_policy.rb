# frozen_string_literal: true

class PlacementPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[lat lon id]
    attributes
  end

  def show?
    return unless record.placeable_type == 'Edge'
    placeable_policy.show?
  end

  private

  def placeable_policy
    @placeable_policy ||= Pundit.policy(context, record.placeable)
  end
end
