# frozen_string_literal: true

class UpdateMotion < UpdateService
  def initialize(resource, attributes: {}, options: {})
    super
    resource.edge.parent = resource.parent_edge(:forum) if resource.question_id_changed? && resource.question_id.nil?
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end
end
