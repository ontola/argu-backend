# frozen_string_literal: true

module UUIDHelper
  def uuid?(string)
    string.match?(/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i)
  end
end
