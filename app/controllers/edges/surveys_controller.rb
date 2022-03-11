# frozen_string_literal: true

class SurveysController < EdgeableController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Survey.svg')
  )

  private

  def update_meta
    super + [
      invalidate_resource_delta(current_resource.menu(:tabs))
    ]
  end
end
