# frozen_string_literal: true

class Ontology
  class Class < LinkedRails::Ontology::Class
    def parent_class
      if ![Edge, ApplicationRecord].include?(klass.superclass)
        klass.superclass.iri
      elsif klass.include?(Edgeable::Content)
        NS.schema.CreativeWork
      else
        NS.schema.Thing
      end
    end
  end
end
