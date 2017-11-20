# frozen_string_literal: true

class Grant < ApplicationRecord
  include Parentable

  # The Edge this Grant is providing rules for
  belongs_to :edge
  belongs_to :group, inverse_of: :grants

  scope :forum_manager, lambda {
    where('role >= ?', Grant.roles[:moderator]).joins(:edge).where(edges: {owner_type: 'Forum'})
  }
  scope :forum_member, -> { member.joins(:edge).where(edges: {owner_type: 'Forum'}) }
  scope :page_manager,
        -> { where('role >= ?', Grant.roles[:moderator]).joins(:edge).where(edges: {owner_type: 'Page'}) }
  scope :page_member, -> { member.joins(:edge).where(edges: {owner_type: 'Page'}) }
  scope :custom, -> { where('group_id > 0') }
  enum role: {spectator: 0, participator: 1, moderator: 2, administrator: 10, staff: 100}

  validates :group, :role, presence: true
  validates :edge, presence: true, uniqueness: {scope: :group}
  validates :role, exclusion: {in: ['staff', :staff, Grant.roles[:staff]]}

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
