# frozen_string_literal: true

class PermittedAction < ApplicationRecord
  ACTIONS = %w[create show update trash destroy].freeze
  RESOURCE_TYPES = %w[Page Forum Question Motion Decision BlogPost Argument Vote Comment].freeze
  has_many :grant_sets_permitted_actions, dependent: :destroy
  has_many :grant_sets, through: :grant_sets_permitted_actions
  validates :action, inclusion: {in: ACTIONS}

  def icon
    parent_type == '*' ? 'check' : 'question'
  end

  def tooltip
    parent_type unless parent_type == '*'
  end

  def to_param
    title
  end
end
