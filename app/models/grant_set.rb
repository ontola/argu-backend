# frozen_string_literal: true

class GrantSet < ApplicationRecord
  RESERVED_TITLES = %w[spectator participator initiator moderator administrator staff].freeze
  has_many :grant_sets_permitted_actions, dependent: :destroy
  has_many :permitted_actions, through: :grant_sets_permitted_actions
  has_many :grants, dependent: :restrict_with_exception
  belongs_to :page

  validates :page, presence: true
  validates :title, uniqueness: {scope: :page_id}

  scope :selectable, -> { where(title: %w[spectator participator initiator administrator]) }

  RESERVED_TITLES.each do |title|
    define_singleton_method title do
      find_by(title: title, page_id: nil)
    end
  end

  def clone(new_title, page)
    cloned = GrantSet.create!(title: new_title, page: page)
    permitted_actions.each do |permitted_action|
      cloned.permitted_actions << permitted_action
    end
    cloned.save!
    cloned
  end

  def display_name
    title
  end

  def self.for_one_action(resource_type, action)
    title = "#{resource_type.underscore}_#{action}"
    find_or_initialize_by(title: title) do |grant_set|
      grant_set.permitted_actions << PermittedAction.find_by!(title: title)
      grant_set.save!(validate: false)
    end
  end
end
