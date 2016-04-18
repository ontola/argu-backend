# frozen_string_literal: true
class Decision < ApplicationRecord
  include Loggable, Happenable, HasLinks, Parentable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :decisionable, polymorphic: true, inverse_of: :decisions
  belongs_to :forum
  belongs_to :forwarded_to, class_name: 'Decision'
  belongs_to :group
  belongs_to :publisher, inverse_of: :decisions, class_name: 'User'
  belongs_to :user, inverse_of: :assigned_decisions
  has_one :decision_activity,
          -> { where("key ~ '*.#{Decision.actioned_keys.join('|')}'") },
          class_name: 'Activity',
          as: :trackable
  enum state: {pending: 0, approved: 1, rejected: 2, forwarded: 3}
  validates :forwarded_to, presence: {message: I18n.t('decisions.forward_failed'), if: :forwarded?}
  validates :happening, presence: true, unless: :pending?
  validates :group, presence: true
  validate :membership_exists
  alias_attribute :title, :display_name
  alias_attribute :description, :content
  parentable :decisionable

  accepts_nested_attributes_for :forwarded_to

  # @return [Array<Symbol>] States that indicate an action was taken on this decision
  def self.actioned_keys
    states.keys[1..-1]
  end

  def display_name
    I18n.t("decisions.#{decisionable.model_name.i18n_key}.#{state}")
  end

  def edited?
    false
  end

  def is_published
    true
  end

  def is_published?
    true
  end

  private

  def membership_exists
    if user.present? && GroupMembership.where(member: user.profile, group: group).empty?
      errors.add(:forwarded_to, I18n.t('decisions.forward_failed'))
    end
  end
end
