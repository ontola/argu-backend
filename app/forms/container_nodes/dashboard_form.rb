# frozen_string_literal: true

class DashboardForm < ContainerNodeForm
  field :display_name
  field :bio, datatype: NS::FHIR[:markdown]
  field :locale
  field :url, url_options
  has_one :default_cover_photo
  has_many :grants, grant_options
end
