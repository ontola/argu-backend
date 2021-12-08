# frozen_string_literal: true

module RDF
  class URISerializer
    include RDF::Serializers::ObjectSerializer
    include LinkedRails::Serializer
  end
end
