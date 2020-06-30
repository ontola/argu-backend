# frozen_string_literal: true

class ProjectPolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
