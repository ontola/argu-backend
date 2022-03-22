# frozen_string_literal: true

class DashboardsController < ContainerNodesController
  has_collection_create_action(
    svg: RDF::URI('https://dptr8y9slmfgv.cloudfront.net/argu/Dashboard.svg')
  )
end
