# frozen_string_literal: true

class CreateConversion < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    attributes[:klass] = class_from_string(attributes[:klass]) if attributes[:klass].is_a?(String)
    super
  end

  def broadcast_event; end

  private

  def class_from_string(klass)
    klass.classify.safe_constantize ||
      resource.edge.convertible_classes.keys.map { |key| key.to_s.classify.constantize }.detect { |k| k.iri == klass }
  end
end
