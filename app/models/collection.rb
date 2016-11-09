# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable,
          Ldable

  attr_accessor :association, :group_by, :member, :id, :parent, :potential_action, :title

  contextualize_with_id(&:id)
  contextualize_as_type 'hydra:Collection'
  contextualize :member, as: 'hydra:member'
  contextualize :title, as: 'schema:name'
  contextualize :group_by, as: 'argu:groupBy'
end
