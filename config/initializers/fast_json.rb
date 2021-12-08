# frozen_string_literal: true

module FastJsonapi
  class Relationship
    def id_hash_from_record(record, params)
      associated_record_type = record_type_for(record, params)
      record_id = record.is_a?(RDF::URI) ? record : record.public_send(id_method_name)

      id_hash(record_id, associated_record_type)
    end
  end
end
