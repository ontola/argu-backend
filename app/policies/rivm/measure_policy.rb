# frozen_string_literal: true

class MeasurePolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description comments_allowed]
    attributes
  end

  private

  def trash?
    super || is_creator?
  end
end
