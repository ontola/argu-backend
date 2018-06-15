# frozen_string_literal: true

class Forum < Edge
  enhance CoverPhotoable
  enhance Createable
  enhance Destroyable
  enhance Discussable
  enhance Motionable
  enhance Moveable
  enhance ProfilePhotoable
  enhance Questionable
  enhance Updateable
  enhance Widgetable

  include Attribution
  include Menuable

  property :display_name, :string, NS::SCHEMA[:name]
  property :bio, :text, NS::SCHEMA[:description]
  property :bio_long, :text, NS::SCHEMA[:text]
  property :cover_photo_attribution, :string, NS::ARGU[:photoAttribution]
  property :discoverable, :boolean, NS::ARGU[:discoverable], default: true
  property :locale, :string, NS::ARGU[:locale], default: 'nl-NL'
  property :default_decision_group_id, :boolean, NS::ARGU[:defaultDecisionGroupId]

  has_many :banners, inverse_of: :forum, dependent: :destroy, primary_key: :uuid
  belongs_to :default_decision_group, class_name: 'Group', foreign_key_property: :default_decision_group_id

  with_collection :motions, pagination: true

  cattr_accessor :default_widgets do
    %i[motions questions]
  end

  # @private
  attr_accessor :tab, :active, :confirmation_string
  attr_writer :public_grant
  alias_attribute :description, :bio

  alias_attribute :name, :display_name
  alias_attribute :description, :bio

  paginates_per 30
  parentable :page

  validates :url, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}

  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :bio, nullify: false

  before_create :set_default_decision_group
  after_save :reset_country
  after_save :reset_public_grant

  scope :top_public_forums, lambda { |limit = 10|
    public_forums.first(limit)
  }
  scope :public_forums, lambda {
    joins(:grants)
      .where(discoverable: true, grants: {group_id: Group::PUBLIC_ID})
      .order('edges.follows_count DESC')
  }

  def children_count(association)
    return super unless association == :motions
    descendants.active.where(owner_type: 'Motion').count
  end

  def default_decision_user
    nil
  end

  def iri_opts
    {root_id: root.url, id: url}
  end

  def language
    locale.split('-').first.to_sym
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present,
  # the first Forum where {Forum#discoverable} is true and a {Grant} for the public {Group} is present
  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Edge.find_by!(uuid: setting)
    end
    forum || Forum.public_forums.first
  end

  def public_grant
    @public_grant ||= grants.find_by(group_id: Group::PUBLIC_ID)&.grant_set&.title || 'none'
  end

  def self.shortnameable?
    true
  end

  def move_to(_new_parent)
    super do
      grants.where('group_id != ?', Group::PUBLIC_ID).destroy_all
    end
  end

  private

  def reset_country
    country_code = locale.split('-').second
    return if country_placement&.country_code == country_code
    place = Place.find_or_fetch_country(country_code)
    placement =
      placements
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
        grants.create!(group_id: Group::PUBLIC_ID, grant_set: GrantSet.find_by!(title: public_grant))
      end
    end
  end

  def set_default_decision_group
    self.default_decision_group =
      parent.grants.joins(:group).find_by(grant_set: GrantSet.administrator, groups: {deletable: false}).group
  end
end
