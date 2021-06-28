# frozen_string_literal: true

class ConversionForm < ApplicationForm
  field :klass_iri,
        sh_in_prop: NS.argu[:convertibleClasses]
end
