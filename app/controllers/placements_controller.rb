# frozen_string_literal: true

class PlacementsController < ParentableController
  skip_before_action :check_if_registered, only: %i[index show]

  private

  def index_includes_collection
    [:place]
  end

  def index_collection
    @index_collection ||=
      policy_scope(
        Placement
          .custom
          .joins('INNER JOIN edges ON placements.placeable_type = \'Edge\' AND placements.placeable_id = edges.uuid')
          .where('? IN (edges.id, edges.parent_id)', parent_resource.id)
          .includes(:place)
      )
  end

  def index_meta
    iri = collection_iri(parent_resource, :placements)
    return [[iri, RDF[:first], RDF[:nil]]] if @index_collection.blank?

    RDF::List.new(
      graph: RDF::Graph.new,
      subject: iri,
      values: @index_collection.map(&:iri)
    ).triples
  end
end
