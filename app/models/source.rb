# frozen_string_literal: true

class Source < Edgeable::Base
  include Menuable

  belongs_to :page, inverse_of: :sources
  has_many :linked_records, dependent: :destroy
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  alias_attribute :display_name, :name
  alias_attribute :url, :shortname

  validates :shortname,
            presence: true,
            length: {minimum: 4, maximum: 75},
            uniqueness: {scope: :page_id},
            format: {with: /\A[_a-zA-Z0-9]*\z/i}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page, presence: true

  after_save :reset_public_grant

  # @!attribute visibility
  # @return [Enum] The visibility of the {Source}
  enum visibility: {open: 1, closed: 2, hidden: 3}

  parentable :page

  # @private
  attr_accessor :tab, :active
  attr_writer :public_grant

  def self.find_by_iri(iri)
    find_by("? LIKE iri_base || '%'", iri)
  end

  def self.find_by_iri!(iri)
    find_by_iri(iri) || raise(ActiveRecord::RecordNotFound)
  end

  def page=(value)
    super value.is_a?(Page) ? value : Page.find_via_shortname!(value)
  end

  def public_grant
    @public_grant ||= grants.find_by(group_id: Group::PUBLIC_ID)&.role || 'none'
  end

  def to_param
    shortname
  end

  private

  def reset_public_grant
    if public_grant == 'none'
      grants.where(group_id: Group::PUBLIC_ID).destroy_all
    else
      grants.joins(:grant_set).where('group_id = ? AND title != ?', Group::PUBLIC_ID, public_grant).destroy_all
      unless grants.joins(:grant_set).find_by(group_id: Group::PUBLIC_ID, grant_sets: {title: public_grant})
        edge.grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.find_by(title: public_grant))
      end
    end
  end
end
