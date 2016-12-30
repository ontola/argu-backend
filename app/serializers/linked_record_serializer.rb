# frozen_string_literal: true
class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serlializer
  include Voteable::Serlializer

  link(:self) { object.class.try(:context_id_factory)&.call(object) if object.persisted? }
  link(:resource) { object.iri }

  attributes :title
end
