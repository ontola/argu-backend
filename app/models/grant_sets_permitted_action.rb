# frozen_string_literal: true
class GrantSetsPermittedAction < ApplicationRecord
  belongs_to :grant_set
  belongs_to :permitted_action
end
