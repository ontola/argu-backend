# frozen_string_literal: true
class PhasePolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super()
    attributes.concat %i(id name description integer end_date end_time finish_phase _destroy)
    attributes.concat %i(name description end_date finish_phase)
    attributes
  end
end
