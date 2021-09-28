# frozen_string_literal: true

class CustomFormFieldsController < EdgeableController
  private

  def update_meta
    meta = super
    meta << [current_resource.iri, NS.rdfv.type, current_resource.rdf_type, delta_iri(:replace)]
    meta
  end
end
