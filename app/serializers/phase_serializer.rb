# frozen_string_literal: true

class PhaseSerializer < BaseSerializer
  attribute :display_name, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :start_date, predicate: NS::SCHEMA[:startDate]
  attribute :end_date, predicate: NS::SCHEMA[:endDate]
end
