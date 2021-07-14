# frozen_string_literal: true

class GrantSet < ApplicationRecord
  RESERVED_TITLES = %w[spectator participator initiator moderator administrator staff].freeze
  SELECTABLE_TITLES = %w[spectator participator initiator administrator].freeze
  has_many :grant_sets_permitted_actions, dependent: :destroy
  has_many :permitted_actions, through: :grant_sets_permitted_actions
  has_many :grants, dependent: :restrict_with_exception
  belongs_to :page, primary_key: :uuid, foreign_key: :root_id, inverse_of: :grant_sets

  validates :page, presence: true
  validates :title, uniqueness: {scope: :root_id}

  scope :selectable, -> { where(title: SELECTABLE_TITLES) }

  RESERVED_TITLES.each do |title|
    define_singleton_method title do
      find_by(title: title, root_id: nil)
    end
  end

  def add(*new_permitted_actions)
    new_permitted_actions.each do |permitted_action|
      GrantSetsPermittedAction.find_or_create_by!(permitted_action: permitted_action, grant_set: self)
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
    I18n.t("roles.types.#{title}", default: title).capitalize
  end

  def description
    I18n.t("roles.descriptions.#{title}", default: nil)&.capitalize
  end

  class << self
    def for_one_action(resource_type, action)
      title = "#{resource_type.underscore}_#{action}"
      find_or_initialize_by(title: title) do |grant_set|
        grant_set.permitted_actions << PermittedAction.find_by!(title: title)
        grant_set.save!(validate: false)
      end
    end

    def reserved(except: [], only: nil)
      titles = only.nil? ? RESERVED_TITLES - except : only
      GrantSet.where(title: titles)
    end

    def requested_index_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
      return unless parent&.enhanced_with?(Grantable)

      LinkedRails::Sequence.new(
        user_context.grant_tree.grant_sets(parent.persisted_edge, group_ids: user_context.user.profile.group_ids),
        id: parent.granted_sets_iri,
        scope: false
      )
    end

    def requested_single_resource(params, _user_context)
      if (/[a-zA-Z]/i =~ params[:id]).nil?
        GrantSet.find_by(id: params[:id])
      else
        GrantSet.find_by(title: params[:id])
      end
    end
  end
end
