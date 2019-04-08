# frozen_string_literal: true

class DistributionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[
      display_name description access_url download_url format license byte_size page language conforms_to
      media_type issued rights status modified
    ]
    attributes
  end
end
