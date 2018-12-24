# frozen_string_literal: true

class WidgetPolicy < RestrictivePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[resource_iri size widget_type]
    attributes
  end

  def create?
    service?
  end
end
