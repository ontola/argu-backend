# frozen_string_literal: true

class BaseSerializer < ActiveModel::Serializer
  link(:self) { object.context_id }
  attribute :type, predicate: RDF[:type]
  attribute :ld_type, key: '@type'

  def id
    ld_id
  end

  def ld_id
    return unless object.respond_to?(:jsonld_context)
    RDF::IRI.new object.context_id
  end

  def service_scope?
    scope&.doorkeeper_scopes&.include? 'service'
  end

  def tenant
    object.forum.url if object.respond_to? :forum
  end

  def type
    RDF::URI(object.context_type)
  end

  def ld_type
    return unless object.respond_to?(:jsonld_context)
    object.context_type
  end
end
