# frozen_string_literal: true

class SwipeToolsController < SurveysController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/SwipeTool.svg')
  )
end
