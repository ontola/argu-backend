# frozen_string_literal: true

class SetupSerializer < BaseSerializer
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :display_name, predicate: NS::SCHEMA[:name], datatype: NS::XSD[:string]
  attribute :organization, predicate: NS::ONTOLA[:organization] do
    ActsAsTenant.current_tenant.try(:iri)
  end
end
