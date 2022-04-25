# frozen_string_literal: true

class PollsController < EdgeableController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Poll.svg')
  )
end
