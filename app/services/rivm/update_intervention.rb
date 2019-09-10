# frozen_string_literal: true

class UpdateIntervention < EdgeableUpdateService
  include UUIDHelper

  def initialize(resource, attributes: {}, options: {})
    if attributes[:employment_id] && !uuid?(attributes[:employment_id])
      attributes[:employment_id] = Employment.find_by!(fragment: attributes[:employment_id]).uuid
    end

    super
  end

  private

  def object_attributes=(obj); end
end
