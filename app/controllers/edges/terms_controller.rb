# frozen_string_literal: true

class TermsController < EdgeableController
  has_collection_create_action(
    form: -> { resource.parent.custom_form&.iri || TermForm }
  )

  private

  def permit_params
    super.merge(body_graph: params[:body_graph])
  end
end
