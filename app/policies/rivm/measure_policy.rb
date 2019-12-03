# frozen_string_literal: true

class MeasurePolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description comments_allowed]
    attributes.concat %i[parent_id] if new_record?
    attributes
  end

  def create?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def show?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end

  def trash?
    super || is_creator?
  end
end
