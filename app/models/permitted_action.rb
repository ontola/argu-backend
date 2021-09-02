# frozen_string_literal: true

class PermittedAction < ApplicationRecord
  ACTIONS = %w[create show update trash destroy].freeze
  RESOURCE_TYPES = %w[Page Forum Question Motion Decision BlogPost ProArgument ConArgument Vote Comment].freeze
  has_many :grant_sets_permitted_actions, dependent: :destroy
  has_many :grant_sets, through: :grant_sets_permitted_actions
  validates :action_name, inclusion: {in: ACTIONS}

  def icon
    parent_type == '*' ? 'check' : 'question'
  end

  def tooltip
    parent_type unless parent_type == '*'
  end

  def to_param
    title
  end

  class << self
    def create_for_grant_sets(type, action, grant_sets)
      permitted_action = PermittedAction.find_or_create_by!(
        title: "#{type.underscore}_#{action}",
        resource_type: type,
        parent_type: '*',
        action_name: action.split('_').first
      )
      grant_sets.each { |grant_set| grant_set.add(permitted_action) }
    end
  end
end
