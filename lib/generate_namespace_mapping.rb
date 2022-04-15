# frozen_string_literal: true

module GenerateNamespaceMapping
  include EmpJsonSerializer

  attr_accessor :ontology

  def generate
    @ontology ||= Ontology.new

    @classes ||= generate_class_mapping
    @properties ||= generate_property_mapping

    intersection = @classes.keys & @properties.keys
    throw "Duplicate keys #{intersection}" if intersection.present?

    @classes.merge(@properties)
  end

  private

  def generate_class_mapping
    @ontology.classes.reduce({}) do |acc, cur|
      if cur.klass.instance_of?(Class)
        Rails.logger.debug "Skipping instance of Class (#{cur})"
        return acc
      end
      iri = cur.iri.to_s
      symbol = predicate_to_symbol(cur.iri, symbolize: :class)
      set_or_add(acc, symbol, iri)
    end
  end

  def set_or_add(acc, symbol, iri) # rubocop:disable Metrics/MethodLength
    merged = if acc[symbol].is_a?(Array)
               [iri].concat(acc[symbol]).uniq
             else
               [iri, acc[symbol]].compact.uniq
             end
    if merged.size == 1
      acc.update({symbol => merged[0]})
    else
      best = merged.min { |a, b| sort_ns(a, b) }
      acc.update({symbol => best})
    end
  end

  def stem(iri)
    hash = iri.index('#')
    if hash.present?
      iri[0..hash]
    else
      iri[0..iri.rindex('/')]
    end
  end

  def generate_property_mapping
    @ontology.properties.reduce({}) do |acc, cur|
      iri = cur.iri.to_s
      symbol = predicate_to_symbol(cur.iri, symbolize: true)
      set_or_add(acc, symbol, iri)
    end
  end

  def has_conflicting_symbol(acc, iri, symbolize)
    symbol = predicate_to_symbol(iri, symbolize: symbolize)
    acc.include?(symbol) && acc[symbol] != iri
  end

  def preferred
    @preferred ||= %w[
      https://ns.ontola.io/form#
      http://www.w3.org/ns/shacl#
      http://schema.org/
      https://argu.co/ns/core#
    ]
  end

  def sort_ns(a, b) # rubocop:disable Metrics/MethodLength, Naming/MethodParameterName
    ia = preferred.index(stem(a))
    ib = preferred.index(stem(b))

    if ia.nil? && ib.nil?
      0
    elsif ia.nil?
      -1
    elsif ib.nil?
      1
    else
      ia - ib
    end
  end
end
