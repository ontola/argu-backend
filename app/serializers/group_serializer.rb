# frozen_string_literal: true
class GroupSerializer < BaseSerializer
  attribute :name, key: :displayName
end
