# frozen_string_literal: true

class ConversionForm < RailsLD::Form
  field :klass, path: NS::ARGU[:convertToClass]
end
