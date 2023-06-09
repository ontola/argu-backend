# frozen_string_literal: true

class GroupMembership < ApplicationRecord
  belongs_to :group

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

  include Cacheable
  include Parentable

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

  scope :active, lambda {
    where('start_date <= statement_timestamp() AND (end_date IS NULL OR end_date > statement_timestamp())')
  }

  with_columns settings: [
    NS.org[:member],
    NS.ontola[:destroyAction]
  ]

  validates :member, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_group_memberships
  validates :group_id, exclusion: {in: [Group::STAFF_ID]}
  validates :member_id, exclusion: {in: [Profile::COMMUNITY_ID]}

  alias edgeable_record page

  paginates_per 30
  parentable :group

  attr_accessor :token

  def iri(**opts)
    return @iri if @iri && opts.empty?

    iri ||= ActsAsTenant.with_tenant(root || ActsAsTenant.current_tenant) { super }
    @iri = iri if opts.empty?
    iri
  end

  def display_name; end

  def publisher
    profile.profileable
  end

  private

  def end_date_after_start_date
    return unless end_date.present? && end_date < start_date

    errors.add(:end_date, "can't be before start date")
  end

  def no_overlapping_group_memberships
    existing = GroupMembership
                 .where(member_id: member_id, group_id: group_id)
                 .where('(start_date, LEAST(end_date, \'infinity\'::timestamp)) OVERLAPS '\
                        '(?, LEAST(?, \'infinity\'::timestamp))',
                        start_date,
                        end_date)
                 .ids
    existing.delete(id)
    return if existing.empty?

    errors.add(:group_id, :taken, value: group_id)
  end

  class << self
    def anonymize(collection)
      # rubocop:disable Rails/SkipsModelValidations
      collection.update_all(member_id: Profile::COMMUNITY_ID, end_date: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def attributes_for_new(opts)
      attrs = super
      attrs[:group] = opts[:parent]
      attrs
    end

    def iri
      [super, NS.org['Membership']]
    end
  end
end
