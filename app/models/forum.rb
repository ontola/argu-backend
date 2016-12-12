# frozen_string_literal: true
class Forum < ApplicationRecord
  include Attribution, Shortnameable, Flowable, Photoable, ProfilePhotoable, Parentable,
          Loggable, Ldable

  belongs_to :page, inverse_of: :forums
  has_many :access_tokens, inverse_of: :item, foreign_key: :item_id, dependent: :destroy
  has_many :banners, inverse_of: :forum
  has_many :shortnames, inverse_of: :forum
  has_many :stepups, inverse_of: :forum
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  has_many :votes, inverse_of: :forum
  # User content
  has_many :arguments, inverse_of: :forum, dependent: :destroy
  has_many :motions, inverse_of: :forum, dependent: :destroy
  has_many :projects, inverse_of: :forum, dependent: :destroy
  has_many :questions, inverse_of: :forum, dependent: :destroy

  # @private
  attr_accessor :tab, :active

  acts_as_ordered_taggable_on :tags
  paginates_per 30
  parentable :page

  validates :shortname, presence: true, length: {minimum: 4, maximum: 75}
  validates :name, presence: true, length: {minimum: 4, maximum: 75}
  validates :page_id, presence: true
  validates :bio, length: {maximum: 90}
  validates :bio_long, length: {maximum: 5000}
  validate :shortnames_count

  def shortnames_count
    errors.add(:shortnames, 'bad') if shortnames.count > max_shortname_count
  end

  after_validation :check_access_token, if: :visible_with_a_link_changed?
  auto_strip_attributes :name, :cover_photo_attribution, squish: true
  auto_strip_attributes :featured_tags, squish: true, nullify: false
  auto_strip_attributes :bio, nullify: false

  before_update :transfer_page, if: :page_id_changed?
  before_update :reset_public_grant, if: :visibility_changed?

  # @!attribute visibility
  # @return [Enum] The visibility of the {Forum}
  enum visibility: {open: 1, closed: 2, hidden: 3} # unrestricted: 0,

  scope :top_public_forums, lambda { |limit = 10|
    where(visibility: Forum.visibilities[:open]).joins(:edge).order('edges.follows_count DESC').first(limit)
  }
  scope :public_forums, lambda {
    where(visibility: Forum.visibilities[:open]).joins(:edge).order('edges.follows_count DESC')
  }

  contextualize_as_type 'argu:Forum'
  contextualize_with_id { |f| Rails.application.routes.url_helpers.forum_url(f, protocol: :https) }
  contextualize :display_name, as: 'schema:name'

  def access_token
    access_token! if visible_with_a_link
  end

  def access_token!
    access_tokens.first.try(:access_token)
  end

  def m_access_tokens
    m_access_tokens! if visible_with_a_link
  end

  def m_access_tokens!
    access_tokens.map(&:access_token)
  end

  def check_access_token
    return unless visible_with_a_link && access_token!.blank?
    access_tokens.build(item: self, profile: page.profile)
  end

  def creator
    page.owner
  end

  def default_decision_group
    edge.granted_groups('manager').first
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

  def full_access_token
    AccessToken.find_by(item: self)
  end

  def page=(value)
    super value.is_a?(Page) ? value : Page.find_via_shortname(value)
  end

  def publisher
    page.owner.profileable
  end

  # @return [Forum] based on the `:default_forum` {Setting}, if not present,
  # the first Forum where {Forum#visibility} is `public`
  def self.first_public
    if (setting = Setting.get(:default_forum))
      forum = Forum.find_via_shortname(setting)
    end
    forum || Forum.public_forums.first
  end

  def featured_tags
    super.split(',')
  end

  def featured_tags=(value)
    super(value.downcase.strip)
  end

  def reset_public_grant
    if open?
      unless grants.find_by(group_id: Group::PUBLIC_GROUP_ID)
        edge.grants.create(group_id: Group::PUBLIC_GROUP_ID, role: Grant.roles['member'])
      end
    else
      grants.where(group_id: Group::PUBLIC_GROUP_ID).destroy_all
    end
  end

  # Is the forum out of its shortname limit
  # @see {max_shortname_count}
  # @return [Boolean] True if the forum has reached its maximum shortname count.
  def shortnames_depleted?
    shortnames.count >= max_shortname_count
  end

  def transfer_page
    Forum.transaction do
      edge.grants.destroy_all
      reset_public_grant
      edge.update(parent: page.edge)
    end
  end
end
