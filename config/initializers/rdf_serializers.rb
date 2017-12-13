# frozen_string_literal: true

require 'rdf_serializers/renderers'

opts = {
  prefixes: Hash[NS.constants.map { |const| [const.to_s.downcase.to_sym, NS.const_get(const)] }]
}

RDFSerializers::Renderers.register(%i[n3 ntriples turtle jsonld rdf], opts)
