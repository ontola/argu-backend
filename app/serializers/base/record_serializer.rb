# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attributes :created_at, :updated_at

  def id
    ld_id
  end
end
