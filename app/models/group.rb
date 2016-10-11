# frozen_string_literal: true
class Group < ApplicationRecord
  include Parentable

  has_many :grants, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, class_name: 'Profile'
  belongs_to :page, required: true, inverse_of: :groups
  belongs_to :forum
  has_many :decisions

  validates :name, length: {maximum: 75}
  validates :visibility, presence: true

  delegate :publisher, to: :page

  enum visibility: {hidden: 0, visible: 1, discussion: 2}
  parentable :page

  def as_json(options)
    super(options.merge(except: [:created_at, :updated_at]))
  end

  def display_name
    name
  end

  delegate :include?, to: :members
end
