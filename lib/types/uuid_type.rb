# frozen_string_literal: true

class UUIDType < ActiveRecord::Type::Value
  include UUIDHelper

  def type
    :uuid
  end

  def cast(value)
    value if uuid?(value)
  end
end
