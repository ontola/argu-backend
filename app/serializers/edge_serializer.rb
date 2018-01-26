# frozen_string_literal: true

class EdgeSerializer < BaseSerializer
  triples :owner_triples

  def owner_triples
    ActiveModelSerializers::SerializableResource.new(object.owner, adapter: :rdf, scope: scope).adapter.triples
  end

  def rdf_subject
    object.owner.iri
  end

  def type
    NS::ARGU[object.owner_type]
  end
end
