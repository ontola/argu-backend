# frozen_string_literal: true
class LinkedRecordSerializer < RecordSerializer
  include Argumentable::Serlializer
  include Voteable::Serlializer

  link(:self) { object.context_id if object.persisted? }
  link(:resource) { object.iri }

  attributes :title, :record_type
end
