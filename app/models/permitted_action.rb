# frozen_string_literal: true

class PermittedAction < ApplicationRecord
  ACTIONS = %w[create show update trash destroy].freeze
  has_many :grant_sets_permitted_actions, dependent: :destroy
  has_many :grant_sets, through: :grant_sets_permitted_actions
  validates :action, inclusion: {in: ACTIONS}
end
