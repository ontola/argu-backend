# frozen_string_literal: true
class Group < ApplicationRecord
  include Edgeable, Ldable

  has_many :grants, dependent: :destroy, inverse_of: :group
  has_many :group_memberships, -> { active }, dependent: :destroy
  has_many :members, through: :group_memberships, class_name: 'Profile'
  belongs_to :page, required: true, inverse_of: :groups
  belongs_to :forum
  has_many :decisions
  accepts_nested_attributes_for :grants, reject_if: :all_blank

  validates :name, presence: true, length: {minimum: 3, maximum: 75}

  scope :custom, -> { where('groups.id != ?', Group::PUBLIC_ID) }

  delegate :publisher, to: :page
  attr_accessor :confirmation_string

  contextualize_as_type 'argu:Group'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.group_url(r, protocol: :https) }

  parentable :page

  PUBLIC_ID = -1

  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at]))
  end

  def display_name
    id == Group::PUBLIC_ID ? I18n.t('groups.public') : name
  end

  delegate :include?, to: :members

  def inherited_grants(edge)
    grants
      .joins(:edge)
      .where(edges: {id: edge.self_and_ancestor_ids})
  end

  def self.public
    Group.find_by(id: Group::PUBLIC_ID)
  end
end
