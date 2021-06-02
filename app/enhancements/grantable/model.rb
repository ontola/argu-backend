# frozen_string_literal: true

module Grantable
  module Model
    extend ActiveSupport::Concern

    def granted_sets_iri
      base_iri = is_a?(Edge) ? persisted_edge&.iri : ActsAsTenant.current_tenant&.iri

      RDF::URI("#{base_iri}/grant_sets") if base_iri
    end
  end
end
