# frozen_string_literal: true

class SurveyForm < ContainerNodeForm
  field :display_name
  field :description
  field :external_iri
  has_one :default_cover_photo
  has_one :custom_placement

  footer do
    actor_selector
  end
end
