# frozen_string_literal: true
class Grant < ApplicationRecord
  include Parentable

  # The Edge this Grant is providing rules for
  belongs_to :edge
  belongs_to :group, inverse_of: :grants
  belongs_to :grant_set

  scope :forum_manager, lambda {
    where('role >= ?', Grant.roles[:manager]).joins(:edge).where(edges: {owner_type: 'Forum'})
  }
  scope :forum_member, -> { member.joins(:edge).where(edges: {owner_type: 'Forum'}) }
  scope :page_manager, -> { where('role >= ?', Grant.roles[:manager]).joins(:edge).where(edges: {owner_type: 'Page'}) }
  scope :page_member, -> { member.joins(:edge).where(edges: {owner_type: 'Page'}) }
  scope :custom, -> { where('group_id != ?', Group::PUBLIC_ID) }

  validates :group, presence: true
  validates :edge, presence: true, uniqueness: {scope: :group}

  deprecate :role
  enum role: {spectate: 0, participate: 1, moderate: 2, administrate: 10}
  parentable :edge

  def display_name
    case edge.owner_type
    when 'Forum'
      edge.owner.display_name
    when 'Page'
      I18n.t('grants.all_forums')
    else
      I18n.t('grants.other')
    end
  end

  def page
    edge.root.owner
  end
end
