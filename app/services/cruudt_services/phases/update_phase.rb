# frozen_string_literal: true
class UpdatePhase < UpdateService
  include Wisper::Publisher

  def initialize(phase, attributes: {}, options: {})
    @phase = phase
    @phase.end_date = Time.current - 1.second if attributes[:finish_phase] == 'true'
    if attributes[:end_date].present? && attributes[:end_time].present?
      attributes[:end_date] = Time.zone.parse [attributes[:end_date], attributes.delete(:end_time)].join(' ')
    end
    super
  end

  def resource
    @phase
  end

  private

  def object_attributes=(obj)
    obj.forum ||= @phase.forum
    obj.creator ||= @phase.creator
  end
end
