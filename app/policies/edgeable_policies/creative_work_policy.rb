# frozen_string_literal: true

class CreativeWorkPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description]
    attributes
  end

  delegate :show?, to: :parent_policy
end
