# frozen_string_literal: true

module UUIDHelper
  def uuid?(id)
    id.is_a?(String) && id.match?(/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i)
  end
end
