# frozen_string_literal: true

class PlacementForm < ApplicationForm
  field :coordinates, input_field: LinkedRails::Form::Field::LocationInput, min_count: 1, max_count: 1

  hidden do
    field :lat
    field :lon
  end
end
