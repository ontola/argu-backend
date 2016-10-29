# frozen_string_literal: true

module Ldable
  extend ActiveSupport::Concern

  included do
    include PragmaticContext::Contextualizable
    contextualize :schema, as: 'http://schema.org/'

    contextualize :created_at, as: 'http://schema.org/dateCreated'
    contextualize :updated_at, as: 'http://schema.org/dateModified'
  end
end
