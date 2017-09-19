# frozen_string_literal: true

class BaseSerializer < ActiveModel::Serializer
  link(:self) { object.context_id }
  attribute :ld_context, key: '@context'
  attribute :ld_type, key: '@type'

  def ld_context
    return unless object.respond_to?(:jsonld_context)
    object.jsonld_context.merge(
      '@vocab': 'http://schema.org/',
      schema: 'http://schema.org/',
      argu: 'https://argu.co/ns/core#'
    )
  end

  def ld_id
    return unless object.respond_to?(:jsonld_context)
    object.context_id
  end

  def service_scope?
    scope&.doorkeeper_scopes&.include? 'service'
  end

  def tenant
    object.forum.url if object.respond_to? :forum
  end

  def ld_type
    return unless object.respond_to?(:jsonld_context)
    object.context_type
  end
end
