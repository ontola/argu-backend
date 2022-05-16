# frozen_string_literal: true

class LinkedRecordSerializer < BaseSerializer
  attribute :same_as, predicate: NS.argu[:linkedRecord], &:external_iri
  statements :external_statements

  def self.external_statements(object, _params)
    object.external_statements
  end
end
