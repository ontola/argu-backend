# frozen_string_literal: true

class ProjectPolicy < EdgePolicy
  permit_attributes %i[display_name description current_phase_id]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator staff]
end
