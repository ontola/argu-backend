# frozen_string_literal: true

module ActiveModelSerializers
  module Adapter
    class N3
      class Triple
        def initialize(subject, predicate, object)
          @subject = RDF::URI(subject)
          @predicate = RDF::URI(predicate)
          @object =
            if object.is_a?(RDF::Resource)
              object
            elsif object.is_a?(ActiveSupport::TimeWithZone)
              RDF::Literal(object.to_datetime)
            else
              RDF::Literal(object)
            end
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
