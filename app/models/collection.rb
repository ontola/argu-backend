# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable

  attr_accessor :association, :collection_entries, :id, :parent

  contextualize_with_id(&:id)
  contextualize :collection, as: 'schema:name'
end
