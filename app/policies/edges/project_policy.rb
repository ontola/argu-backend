# frozen_string_literal: true

class ProjectPolicy < EdgePolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[current_phase_id], new_record: false
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator]
end
