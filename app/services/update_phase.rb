class UpdatePhase < UpdateService
  include Wisper::Publisher

  def initialize(phase, attributes = {}, options = {})
    @phase = phase
    @phase.end_date = Time.current if attributes[:finish_phase] == 'true'
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
