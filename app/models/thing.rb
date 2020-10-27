# frozen_string_literal: true

class Thing < Edge
  enhance CoverPhotoable

  has_many :linked_edges, through: :properties

  def action_triples
    []
  end

  def display_name
    properties.find_by(predicate: [NS::SCHEMA.name.to_s, NS::FOAF.name.to_s, NS::RDFS.label.to_s])&.value
  end

  def property_statements
    association_statements +
      properties
        .reject { |prop| prop.predicate == RDF.type || prop.type == 'linked_edge_id' }
        .map { |prop| RDF::Statement.new(iri, prop.predicate, prop.value) }
  end

  def rdf_type
    properties
      .detect { |prop| prop.predicate == RDF.type }
      &.value || NS::SCHEMA.Thing
  end

  private

  def association_predicates
    properties
      .select { |prop| prop.type == 'linked_edge_id' }
      .map(&:predicate)
      .uniq
  end

  def association_sequence(predicate, association)
    sequence = LinkedRails::Sequence.new(association)
    [[iri, predicate, sequence.node]] +
      serializable_resource(sequence, {}).triples
  end

  def association_statements
    association_predicates.flat_map do |predicate|
      association = linked_edge_association(predicate)
      if association.count == 1
        [[iri, predicate, association.first]]
      else
        association_sequence(predicate, association)
      end
    end
  end

  def iri_template_name
    :edges_iri
  end

  def linked_edge_association(predicate)
    associations ||= {}
    associations[predicate] ||=
      properties
        .order(:order)
        .select { |prop| prop.type == 'linked_edge_id' && prop.predicate == predicate }
        .map { |prop| prop.linked_edge.iri }
  end
end
