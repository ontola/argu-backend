# frozen_string_literal: true
class GrantSet < ApplicationRecord
  has_many :grant_sets_permitted_actions
  has_many :permitted_actions, through: :grant_sets_permitted_actions
  has_many :grants
end
