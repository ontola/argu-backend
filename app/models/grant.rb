# frozen_string_literal: true
class Grant < ApplicationRecord
  # The Edge this Grant is providing rules for
  belongs_to :edge
  belongs_to :group

  scope :forum_manager, -> { manager.joins(:edge).where(edges: {owner_type: 'Forum'}) }
  scope :forum_member, -> { member.joins(:edge).where(edges: {owner_type: 'Forum'}) }
  scope :page_manager, -> { manager.joins(:edge).where(edges: {owner_type: 'Page'}) }
  scope :page_member, -> { member.joins(:edge).where(edges: {owner_type: 'Page'}) }

  validates :group, :role, :edge, presence: true

  enum role: {member: 1, manager: 2}

  def page
    edge.root.owner
  end
end
