# frozen_string_literal: true

class LinkedRecordSerializer < BaseSerializer
  statements :external_statements

  def self.external_statements(object, _params)
    object.external_statements
  end
end
