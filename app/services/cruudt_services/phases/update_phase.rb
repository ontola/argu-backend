# frozen_string_literal: true
class UpdatePhase < UpdateService
  def initialize(phase, attributes: {}, options: {})
    @resource = phase
    update_parent(attributes.delete(:parent))
    resource.end_date = Time.current - 1.second if attributes[:finish_phase] == 'true'
    if attributes[:end_date].present? && attributes[:end_time].present?
      attributes[:end_date] = Time.zone.parse [attributes[:end_date], attributes.delete(:end_time)].join(' ')
    end
    super
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
