# frozen_string_literal: true
class Profile < ApplicationRecord
  include Photoable, ProfilePhotoable

  # Currently hardcoded to User (whilst it can also be a Profile)
  # to make the mailer implementation more efficient
  # has_one :profileable, class_name: 'User'
  belongs_to :profileable,
             polymorphic: true,
             inverse_of: :profile
  rolify after_remove: :role_removed, before_add: :role_added

  before_destroy :anonymize_dependencies
  has_many :access_tokens, dependent: :destroy
  has_many :activities, -> { order(:created_at) }, as: :owner, dependent: :restrict_with_exception
  has_many :edges, through: :groups
  has_many :granted_edges_scope, through: :grants, source: :edge, class_name: 'Edge'
  has_many :grants, through: :groups
  has_many :group_memberships, foreign_key: :member_id, inverse_of: :member, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :pages, inverse_of: :owner, foreign_key: :owner_id, dependent: :restrict_with_exception
  has_many :votes, inverse_of: :voter, foreign_key: :voter_id, dependent: :destroy
  # User content
  has_many :arguments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :blog_posts, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :comments, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :motions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :projects, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :questions, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :vote_events, inverse_of: :creator, foreign_key: 'creator_id', dependent: :restrict_with_exception
  has_many :uploaded_photos,
           class_name: 'Photo',
           inverse_of: :creator,
           foreign_key: 'creator_id',
           dependent: :restrict_with_exception

  delegate :context_id, to: :profileable

  validates :name, presence: true, length: {minimum: 3, maximum: 75}, if: :requires_name?
  validates :about, length: {maximum: 3000}

  auto_strip_attributes :name, squish: true
  auto_strip_attributes :about, nullify: false

  COMMUNITY_ID = 0

  def as_json(options)
    # Hide profileable for the more friendly actor
    super(options.merge(except: [:profileable, :profileable_type, :profileable_id], methods: [:actor_type, :actor_id]))
  end

  def actor_type
    profileable_type
  end

  def actor_id
    profileable_id
  end

  def self.community
    Profile.find(Profile::COMMUNITY_ID)
  end

  def confirmed?
    profileable.try :confirmed?
  end

  # http://schema.org/description
  def description
    about
  end

  def display_name
    profileable.try(:display_name) || name.presence
  end

  def email
    profileable.try :email
  end

  def forums
    granted_records('Forum')
  end

  def forum_ids(role = nil)
    @forum_ids ||= {}
    @forum_ids[role] ||= granted_record_ids('Forum', role)
                           .concat(Forum.where(page: granted_record_ids('Page', role)).ids)
                           .uniq
  end

  def joined_forum_ids(role = nil)
    forum_ids(role).join(',').presence
  end

  def granted_edges(owner_type = nil, role = nil)
    scope = granted_edges_scope
    scope = scope.where(owner_type: owner_type) if owner_type.present?
    scope = scope.where(grants: {role: Grant.roles[role]}) if role.present?
    scope
  end

  def granted_edge_ids(owner_type = nil, role = nil)
    granted_edges(owner_type, role).pluck(:id)
  end

  def granted_records(owner_type, role = nil)
    owner_type.constantize.where(id: granted_record_ids(owner_type, role))
  end

  def granted_record_ids(owner_type, role = nil)
    granted_edges(owner_type, role).pluck(:owner_id)
  end

  def group_ids
    super.append(Group::PUBLIC_ID)
  end

  def owner
    profileable
  end
  deprecate :owner

  def page_ids(role = :manager)
    @page_ids ||= {}
    @page_ids[role] ||= granted_record_ids('Page', role)
  end

  def profile_frozen?
    has_role? 'frozen'
  end

  def url
    profileable.presence && profileable.url.presence
  end

  # TODO: Crashes if false
  delegate :finished_intro?, to: :profileable

  def visible_votes_for(user)
    votes
      .joins(edge: {parent: :parent})
      .where(voteable_type: %w(Question Motion), parents_edges_2: {trashed_at: nil})
      .joins('LEFT OUTER JOIN forums ON votes.forum_id = forums.id')
      .where('forums.visibility = ? OR "forums"."id" IN (?)',
             Forum.visibilities[:open],
             user&.profile&.forum_ids)
      .order(created_at: :desc)
      .select('votes.*, forums.visibility')
  end

  # ######Methods########
  def voted_on?(item)
    Vote.where(voter_id: id,
               voter_type: self.class.name,
               voteable_id: item.id,
               voteable_type: item.class.to_s)
      .last
      .try(:for) == 'pro'
  end

  # Warn: Doesn't check for parent deletion
  def votes_questions_motions
    votes.where("voteable_type = 'Question' OR voteable_type = 'Motion'")
  end

  def freeze
    add_role :frozen
  end

  # Returns the preffered forum of the user, based on their last forum visit
  def preferred_forum
    last_forum = Argu::Redis.get("profile:#{id}:last_forum")

    (Forum.find_by(id: last_forum) if last_forum.present?) ||
      granted_records('Forum').first ||
      Forum.first_public
  end

  def requires_name?
    profileable.class == Page
  end

  def member_of?(tenant)
    tenant.present? && granted_edges.include?(tenant.edge)
  end

  def owner_of(tenant)
    return false unless tenant.present?
    case tenant
    when Forum
      self == tenant.page.owner
    when Page
      self == tenant.owner
    end
  end

  def unfreeze
    remove_role :frozen
  end

  private

  # Sets the dependent foreign relations to the Community profile
  def anonymize_dependencies
    %w(comments motions arguments questions blog_posts projects vote_events activities).each do |association|
      association
        .classify
        .constantize
        .anonymize(send(association))
    end
    Photo.anonymize(uploaded_photos)
  end

  def role_added(role)
    # if self.profile_frozen?
    # Send mail or notification to user that he has been unfrozen
    # end
  end

  def role_removed(role)
    # if self.profile_frozen?
    # Send mail or notification to user that he has been frozen
    # end
  end
end
