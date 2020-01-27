# frozen_string_literal: true

class ProjectPolicy < EdgePolicy
  def permitted_attribute_names
    super + %i[display_name description]
  end
end
