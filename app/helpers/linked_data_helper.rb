# frozen_string_literal: true

module LinkedDataHelper
  # Converts a serialized graph from a multipart request body to a nested
  # attributes hash.
  #
  # The graph sent to the server should be sent under the `ll:graph` form name.
  # The entrypoint for the graph is the `ll:targetResource` subject, which is
  # assumed to be the resource intended to be targeted by the request (i.e. the
  # resource to be created, updated, or deleted).
  #
  # @return [Hash] A hash of attributes, empty if no statements were given.
  def params_from_graph(params)
    request_graph = params["<#{NS::LL[:graph].value}>"]
    return {} if request_graph.nil?

    graph = RDF::Graph.load(request_graph.tempfile.path, content_type: request_graph.content_type)
    param_object = HashWithIndifferentAccess.new
    param_object[model_name] = parse_resource(
      graph,
      NS::LL[:targetResource],
      model_name.to_s.classify.constantize,
      params
    )

    param_object
  end

  private

  # Retrieves the attribute-predicate mapping from the serializer.
  #
  # Used to convert incoming predicates back to their respective attributes.
  def model_attribute_map(klass)
    @_model_attribute_map ||= {}
    @_model_attribute_map[klass] ||=
      model_serializer(klass)
        ._attributes_data
        .values
  end

  # Retrieves the reflections-predicate mapping from the serializer.
  #
  # Used to convert incoming predicates back to their respective reflections.
  def model_reflections_map(klass)
    @_model_reflections_map ||= {}
    @_model_reflections_map[klass] ||=
      model_serializer(klass)
        ._reflections
        .values
  end

  def model_serializer(klass)
    @model_serializer ||= {}
    @model_serializer[klass] ||=
      "#{klass.name.underscore}_serializer"
        .classify
        .constantize
  end

  # Recursively parses a resource from graph
  def parse_resource(graph, subject, klass, base_params)
    HashWithIndifferentAccess[
      graph
        .query([subject])
        .map { |statement| parse_statement(graph, statement, klass, base_params) }
        .compact
    ]
  end

  def parse_statement(graph, statement, klass, base_params)
    attribute = model_attribute_map(klass).find { |opt| opt.options[:predicate] == statement.predicate }
    return parsed_attribute(attribute.name, statement.object.value, base_params) if attribute

    association = model_reflections_map(klass).find { |opt| opt.options[:predicate] == statement.predicate }
    return if association.blank?
    parsed_association(
      graph,
      statement.object,
      klass,
      association.options[:association] || association.name,
      base_params
    )
  end

  def parsed_association(graph, object, klass, association, base_params)
    association_klass = klass.reflect_on_association(association).klass
    nested_resources =
      if graph.query([object, NS::RDFV[:first], nil]).present?
        RDF::List.new(subject: object, graph: graph)
          .map { |nested| parse_resource(graph, nested, association_klass, base_params) }
      else
        parse_resource(graph, object, association_klass, base_params)
      end
    ["#{association}_attributes", nested_resources]
  end

  def parsed_attribute(key, value, base_params)
    [key, value.starts_with?(NS::LL['blobs/']) ? base_params["<#{value}>"] : value]
  end
end
