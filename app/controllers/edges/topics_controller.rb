# frozen_string_literal: true

class TopicsController < DiscussionsController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Topic.svg')
  )
end
