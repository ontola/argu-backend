
class UpdateDecision < UpdateService
  include Wisper::Publisher

  def initialize(decision, attributes: {}, options: {})
    @decision = decision
    resource.publisher = options[:publisher]
    resource.creator = options[:creator]
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
      obj.recipient ||= resource.decisionable
      obj.is_published ||= true
    when Decision
      obj.state ||= 0
      obj.decisionable ||= resource.decisionable
      obj.forum ||= resource.forum
      obj.edge ||= obj.build_edge(
        user: resource.decisionable.publisher,
        parent: resource.decisionable.edge)
    end
  end
end
