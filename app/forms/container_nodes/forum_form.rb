# frozen_string_literal: true

class ForumForm < ContainerNodeForm
  field :display_name
  field :bio, datatype: NS.fhir[:markdown]
  field :url, url_options
  has_one :default_cover_photo
  has_one :custom_placement
  has_many :grants, grant_options
end
