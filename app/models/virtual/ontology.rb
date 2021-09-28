# frozen_string_literal: true

class Ontology < LinkedRails::Ontology
  include Cacheable

  class << self
    def requested_resource(opts, _user_context)
      LinkedRecord.find_by(external_iri: opts[:iri]) || super
    end
  end
end
