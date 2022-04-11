# frozen_string_literal: true

class UpdateEdge < UpdateService
  private

  def assign_nested_attributes(parent, obj) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    obj.creator ||= parent.creator if obj.respond_to?(:creator=)
    obj.publisher ||= parent.publisher if obj.respond_to?(:publisher=)
    obj.parent ||= parent if obj.respond_to?(:parent=)
    obj.is_published ||= true if obj.respond_to?(:is_published=)
  end
end
