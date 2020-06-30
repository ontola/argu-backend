# frozen_string_literal: true

class MeasurePolicy < EdgePolicy
  permit_attributes %i[display_name description comments_allowed]
  permit_attributes %i[parent_id], new_record: true

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
