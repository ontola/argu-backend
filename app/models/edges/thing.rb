# frozen_string_literal: true

class Thing < Edge
  include Empathy::EmpJson::Helpers::Parsing

  enhance CoverPhotoable

  has_many :linked_edges, through: :properties

  def action_triples
    []
  end

  def assign_slice(slice)
    slice['.'].each do |key, values|
      next if key == '_id'

      (values.is_a?(Array) ? values : [values]).each do |value|
        parsed_value = emp_to_primitive(value)
        properties << Property.build(self, key, parsed_value) unless parsed_value.is_a?(RDF::Node)
      end
    end
  end

  def display_name
    properties.find_by(predicate: [NS.schema.name.to_s, NS.foaf.name.to_s, NS.rdfs.label.to_s])&.value
  end

  def property_statements
    association_statements +
      properties
        .reject { |prop| prop.predicate == RDF.type || prop.type == 'linked_edge_id' }
        .map { |prop| RDF::Statement.new(iri, prop.predicate, prop.value) }
  end

  def rdf_type
    rdf_type_property&.value || NS.schema.Thing
  end

  def rdf_type=(type)
    (rdf_type_property || properties.build(predicate: RDF.type)).iri = type
  end

  private

  def association_predicates
    properties
      .select { |prop| prop.type == 'linked_edge_id' }
      .map(&:predicate)
      .uniq
  end

  def association_sequence(predicate, association)
    sequence = LinkedRails::Sequence.new(association, scope: false)
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

  def rdf_type_property
    properties.detect { |prop| prop.predicate == RDF.type }
  end
end
