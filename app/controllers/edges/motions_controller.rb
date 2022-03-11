# frozen_string_literal: true

class MotionsController < DiscussionsController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Motion.svg')
  )
end
