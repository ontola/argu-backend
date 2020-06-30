# frozen_string_literal: true

class SetupSerializer < BaseSerializer
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :first_name, predicate: NS::SCHEMA[:givenName], datatype: NS::XSD[:string]
  attribute :last_name, predicate: NS::SCHEMA[:familyName], datatype: NS::XSD[:string]
  attribute :organization, predicate: NS::ONTOLA[:organization] do
    ActsAsTenant.current_tenant.try(:iri)
  end
end
