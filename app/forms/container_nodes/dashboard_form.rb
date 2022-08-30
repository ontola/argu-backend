# frozen_string_literal: true

class DashboardForm < ContainerNodeForm
  field :display_name
  field :bio, datatype: NS.fhir[:markdown]
  field :url, **url_options
  has_one :default_cover_photo
  grants_group
end
