# frozen_string_literal: true

class UpdateIntervention < UpdateEdge
  include UUIDHelper

  def initialize(resource, attributes: {}, options: {})
    if attributes[:employment_id] && !uuid?(attributes[:employment_id])
      attributes[:employment_id] = Employment.find_by!(fragment: attributes[:employment_id]).uuid
    end

    super
  end
end
