# frozen_string_literal: true

class CustomFormForm < ContainerNodeForm
  field :display_name
  has_many :grants, **grant_options
end
