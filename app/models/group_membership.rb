# frozen_string_literal: true
class GroupMembership < ApplicationRecord
  include Parentable

  belongs_to :group
  belongs_to :member,
             inverse_of: :group_memberships,
             class_name: 'Profile'
  belongs_to :profile
  has_one :page,
          through: :group
  has_one :user,
          through: :member,
          source: :profileable,
          source_type: :User
  has_many :grants, through: :group
  scope :active, -> { where('end_date IS NULL OR end_date > ?', DateTime.current) }
  validates :group_id, presence: true, uniqueness: {scope: :member_id}
  validates :member_id, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date

  paginates_per 30
  parentable :group

  attr_accessor :token

  def publisher
    edge.user
  end

  private

  def end_date_after_start_date
    return unless end_date.present? && end_date < start_date
    errors.add(:end_date, "can't be before start date")
  end
end
