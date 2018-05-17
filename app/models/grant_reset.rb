# frozen_string_literal: true

class GrantReset < ApplicationRecord
  belongs_to :edge, inverse_of: :grant_resets, primary_key: :uuid
end
