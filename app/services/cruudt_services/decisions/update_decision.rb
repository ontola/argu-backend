# frozen_string_literal: true
class UpdateDecision < UpdateService
  include Wisper::Publisher

  def initialize(decision, attributes: {}, options: {})
    @decision = decision
    super
  end

  def resource
    @decision
  end

  private

  def object_attributes=(obj)
    case obj
    when Activity
      obj.forum ||= resource.forum
      obj.owner ||= resource.creator
      obj.key ||= "#{resource.state}.happened"
      obj.recipient ||= resource.decisionable.owner
      obj.is_published ||= true
    end
  end
end
