# frozen_string_literal: true
class Page < ApplicationRecord
  has_many :groups, dependent: :destroy, inverse_of: :page
  include Edgeable, Shortnameable, Ldable

  has_one :profile, dependent: :destroy, as: :profileable, inverse_of: :profileable
  accepts_nested_attributes_for :profile
  belongs_to :owner, class_name: 'Profile', inverse_of: :pages
  has_many :forums, dependent: :restrict_with_exception, inverse_of: :page
  has_many :sources, dependent: :restrict_with_exception, inverse_of: :page
  has_many :profile_vote_matches, through: :profile, source: :vote_matches

  attr_accessor :confirmation_string, :tab, :active

  delegate :description, to: :profile

  validates :shortname, presence: true, length: {minimum: 3, maximum: 50}
  validates :profile, :owner_id, :last_accepted, presence: true

  after_create :create_default_groups

  enum visibility: {open: 1, closed: 2, hidden: 3} # unrestricted: 0,

  with_collection :vote_matches,
                  association: :profile_vote_matches,
                  pagination: true,
                  url_constructor: :page_vote_matches_url

  contextualize_as_type 'schema:Organization'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.page_url(r.id, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :about, as: 'schema:description'

  def build_profile(*options)
    super(*options) if profile.nil?
  end

  def display_name
    if profile.present?
      profile.name || url
    else
      url
    end
  end

  def finished_intro?
    true
  end

  def email
    'anonymous'
  end

  def publisher
    owner.profileable
  end

  def root_object?
    true
  end

  private

  def create_default_groups
    %w(super_admin manager).each do |role|
      group = Group.new(
        name: role.humanize.pluralize,
        name_singular: role.capitalize,
        page: self,
        deletable: role != :super_admin
      )
      group.grants << Grant.new(role: Grant.roles[role.to_sym], edge: edge)
      group.edge = Edge.new(user: publisher, parent: edge)
      group.save!
    end
    service = CreateGroupMembership.new(
      edge.groups.first.edge,
      attributes: {member: owner, profile: owner},
      options: {publisher: owner.profileable, creator: owner}
    )
    service.on(:create_group_membership_failed) do |gm|
      raise gm.errors.full_messages
    end
    service.commit
  end
end
