# frozen_string_literal: true

module ActiveModelSerializers
  module Adapter
    class N3
      class Triple
        def initialize(subject, predicate, object)
          @subject = RDF::IRI.new subject
          @predicate = RDF::IRI.new predicate
          @object = object.is_a?(RDF::Resource) ? object : RDF::Literal(object)
        end

        def to_s
          "#{triple.join(' ')} .\n"
        end

        private

        def triple
          [RDF::NTriples.serialize(@subject), RDF::NTriples.serialize(@predicate), RDF::NTriples.serialize(@object)]
        end
      end
    end
  end
end
