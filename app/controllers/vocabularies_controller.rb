# frozen_string_literal: true

class VocabulariesController < ApplicationController
  active_response :show

  private

  def add_class_data(graph, klass, iri) # rubocop:disable Metrics/AbcSize
    graph << RDF::Statement.new(iri, RDF[:type], NS::RDFS[:Class])
    add_subclasses(graph, iri, klass)
    add_input_select_property(graph, iri, klass)
    add_class_label(graph, iri, klass, :en)
    add_class_label(graph, iri, klass, :nl)
    add_class_description(graph, iri, klass, :en)
    add_class_description(graph, iri, klass, :nl)
    add_class_icon(graph, iri, klass)

    klass.predicate_mapping.each do |property_iri, value|
      graph << RDF::Statement.new(property_iri, RDF[:type], RDF[:Property])
      add_property_label(graph, property_iri, klass, value.name, :en)
      add_property_label(graph, property_iri, klass, value.name, :nl)
      add_property_icon(graph, property_iri, value.options[:image])
    end
  end

  def add_class_description(graph, iri, klass, locale)
    label = I18n.t("#{klass.name.tableize}.tooltips.info", default: nil, locale: locale)
    return if label.blank?

    graph << RDF::Statement.new(iri, NS::SCHEMA[:description], RDF::Literal.new(label, language: locale))
  end

  def add_class_icon(graph, iri, klass)
    icon = icon_for(klass)
    return if icon.blank?

    graph << RDF::Statement.new(iri, NS::SCHEMA[:image], RDF::URI("http://fontawesome.io/icon/#{icon}"))
  end

  def add_class_label(graph, iri, klass, locale)
    label = I18n.t("#{klass.name.tableize}.type", default: klass.name.underscore.humanize, locale: locale)

    graph << RDF::Statement.new(iri, NS::RDFS[:label], RDF::Literal.new(label, language: locale))
  end

  def add_input_select_property(graph, iri, klass)
    graph << RDF::Statement.new(iri, NS::ONTOLA['forms/inputs/select/displayProp'], klass.input_select_property)
  end

  def add_property_icon(graph, property_iri, icon)
    return if icon.blank?

    graph << RDF::Statement.new(property_iri, NS::SCHEMA[:image], RDF::URI("http://fontawesome.io/icon/#{icon}"))
  end

  def add_property_label(graph, property_iri, klass, name, locale)
    label = RailsLD.attribute_label_translation.call(klass.model_name.i18n_key, name, locale)
    return if label.blank?

    graph << RDF::Statement.new(property_iri, NS::RDFS[:label], RDF::Literal.new(label, language: locale))
  end

  def add_subclasses(graph, iri, klass)
    parent =
      if ![Edge, ApplicationRecord].include?(klass.superclass)
        klass.superclass.iri
      elsif klass.include?(Edgeable::Content)
        NS::SCHEMA[:CreativeWork]
      else
        NS::SCHEMA[:Thing]
      end
    graph << RDF::Statement.new(iri, NS::RDFS[:subClassOf], parent.is_a?(Array) ? parent.first : parent)
  end

  def show_success
    respond_with_resource(resource: vocab_graph)
  end

  def vocab_graph
    graph = ::RDF::Graph.new
    ApplicationRecord.descendants.each do |klass|
      iri = klass.iri.is_a?(Array) ? klass.iri.first : klass.iri
      add_class_data(graph, klass, iri)
    end
    graph
  end
end
