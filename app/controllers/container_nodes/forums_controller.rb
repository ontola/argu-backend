# frozen_string_literal: true

class ForumsController < ContainerNodesController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Forum.svg')
  )
end
