# frozen_string_literal: true

class CreateIntervention < CreateEdge
  include UUIDHelper

  def initialize(resource, attributes: {}, options: {})
    if attributes[:employment_id] && !uuid?(attributes[:employment_id])
      attributes[:employment_id] = Employment.find_by!(id: attributes[:employment_id]).uuid
    end

    super
  end
end
