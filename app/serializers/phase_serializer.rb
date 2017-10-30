# frozen_string_literal: true

class PhaseSerializer < BaseSerializer
  attribute :display_name, predicate: RDF::SCHEMA[:name]
  attribute :description, predicate: RDF::SCHEMA[:description]
  attribute :start_date, predicate: RDF::SCHEMA[:startDate]
  attribute :end_date, predicate: RDF::SCHEMA[:endDate]
end
