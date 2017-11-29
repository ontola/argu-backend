# frozen_string_literal: true

class PhasePolicy < EdgeablePolicy
  def permitted_attributes(force = false)
    attributes = super()
    attributes.concat %i[id name description integer end_date end_time finish_phase _destroy] if force || create?
    attributes.concat %i[name description end_date finish_phase] if update?
    attributes
  end
end
