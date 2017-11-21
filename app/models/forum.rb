# frozen_string_literal: true

class Forum < Edgeable::Base
  include Discussable
  include Questionable
  include Motionable
  include ProfilePhotoable
  include Photoable
  include Shortnameable
  include Attribution
  include Menuable
  include Widgetable

  belongs_to :page, inverse_of: :forums
  belongs_to :default_decision_group, class_name: 'Group'
  has_many :banners, inverse_of: :forum, dependent: :destroy
  has_many :shortnames, inverse_of: :forum, dependent: :destroy
  has_many :votes, inverse_of: :forum, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :forum, dependent: :destroy
  has_many :blog_posts, inverse_of: :forum, dependent: :destroy
  has_many :comments, inverse_of: :forum, dependent: :destroy
  has_many :motions, inverse_of: :forum, dependent: :destroy
  has_many :direct_motions, -> { where(question_id: nil) }, class_name: 'Motion', inverse_of: :forum
  has_many :questions, inverse_of: :forum, dependent: :destroy

  with_collection :motions,
                  pagination: true,
                  association: :direct_motions

  default_widgets :motions, :questions

  # @private
  attr_accessor :tab, :active, :confirmation_string
  attr_writer :public_grant

  paginates_per 30
  parentable :page

  validates :shortname, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page, presence: true
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}
  validate :shortnames_count

  def shortnames_count
    errors.add(:shortnames, 'bad') if shortnames.count > max_shortname_count
  end

  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :bio, nullify: false

  before_create :set_default_decision_group
  before_update :transfer_page, if: :page_id_changed?
  after_save :reset_country
  after_save :reset_public_grant

  # @!attribute visibility
  # @return [Enum] The visibility of the {Forum}
  enum visibility: {open: 1, closed: 2, hidden: 3} # unrestricted: 0,

  scope :top_public_forums, lambda { |limit = 10|
    public_forums.first(limit)
  }
  scope :public_forums, lambda {
    joins(edge: :grants)
      .where(discoverable: true, grants: {group_id: Group::PUBLIC_ID})
      .order('edges.follows_count DESC')
  }

  def children_count(association)
    return edge.children_count(association) unless association == :motions
    edge.descendants.published.untrashed.where(owner_type: 'Motion').count
  end

  def creator
    page.owner
  end

  def default_decision_user
    nil
  end

  def display_name
    name
  end

  # http://schema.org/description
  def description
    bio
  end

  def self.find(*ids)
    shortname = ids.length == 1 && ids.first.instance_of?(String) && ids.first
    if shortname && shortname.to_i.zero?
      find_via_shortname(shortname)
    else
      super(*ids)
    end
  end

  def iri_opts
    {shortname: url}
  end

  def language
    locale.split('-').first.to_sym
  end

  def page=(value)
    super value.is_a?(Page) ? value : Page.find_via_shortname!(value)
  end

  def publisher
    page.owner.profileable
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present,
  # the first Forum where {Forum#discoverable} is true and a {Grant} for the public {Group} is present
  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Forum.find_via_shortname!(setting)
    end
    forum || Forum.public_forums.first
  end

  def public_grant
    @public_grant ||= grants.find_by(group_id: Group::PUBLIC_ID)&.grant_set&.title || 'none'
  end

  # Is the forum out of its shortname limit
  # @see {max_shortname_count}
  # @return [Boolean] True if the forum has reached its maximum shortname count.
  def shortnames_depleted?
    shortnames.count >= max_shortname_count
  end

  def transfer_page
    Forum.transaction do
      edge.grants.where('group_id != ?', Group::PUBLIC_ID).destroy_all
      edge.update(parent: page.edge)
    end
  end

  private

  def reset_country
    country_code = locale.split('-').second
    return if edge.country_placement&.country_code == country_code
    place = Place.find_or_fetch_country(country_code)
    placement =
      edge
        .placements
        .country
        .first_or_create do |p|
        p.creator = creator
        p.publisher = publisher
        p.place = place
      end
    placement.update!(place: place) unless placement.place == place
  end

  def reset_public_grant
    if public_grant == 'none'
      grants.where(group_id: Group::PUBLIC_ID).destroy_all
    else
      grants.joins(:grant_set).where('group_id = ? AND title != ?', Group::PUBLIC_ID, public_grant).destroy_all
      unless grants.joins(:grant_set).find_by(group_id: Group::PUBLIC_ID, grant_sets: {title: public_grant})
        edge.grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.find_by!(title: public_grant))
      end
    end
  end

  def set_default_decision_group
    self.default_decision_group =
      page.grants.joins(:group).find_by(grant_set: GrantSet.administrator, groups: {deletable: false}).group
  end
end
