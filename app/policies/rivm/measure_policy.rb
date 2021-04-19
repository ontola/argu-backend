# frozen_string_literal: true

class MeasurePolicy < EdgePolicy
  permit_attributes %i[display_name description comments_allowed second_opinion contact_info more_info measure_owner]
  permit_attributes %i[second_opinion_by], has_values: {second_opinion: true}
  permit_attributes %i[attachment_published_at], has_properties: {attachment_collection: true}
  permit_array_attributes %i[phase_ids category_ids]

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
