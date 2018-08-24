# frozen_string_literal: true

class FormOptionSerializer < BaseSerializer
  attribute :label, predicate: NS::SCHEMA[:name]
  delegate :type, to: :object
end
