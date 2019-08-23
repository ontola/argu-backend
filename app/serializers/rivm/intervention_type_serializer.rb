# frozen_string_literal: true

class InterventionTypeSerializer < ContentEdgeSerializer
  private

  def parent
    Dashboard.find_via_shortname('maatregelen')
  end
end
