# frozen_string_literal: true
include ActionView::Helpers::NumberHelper

class Motion < ApplicationRecord
  include Trashable, Argumentable, Voteable, Parentable, ForumTaggable, Attribution, HasLinks, Convertible, Loggable,
          BlogPostable, Timelineable, PublicActivity::Common, Flowable, Placeable, Photoable,
          Decisionable, Ldable, ActivePublishable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :forum, inverse_of: :motions
  belongs_to :publisher, class_name: 'User'

  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'

  attr_accessor :current_vote

  before_save :cap_title

  contextualize_as_type 'argu:Motion'
  contextualize_with_id { |m| Rails.application.routes.url_helpers.motion_url(m, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :content, as: 'schema:text'
  contextualize :current_vote, as: 'argu:currentVote'

  convertible questions: %i(taggings activities blog_posts)
  counter_cache true
  paginates_per 30
  parentable :question, :project, :forum
  resourcify

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :forum, :creator, presence: true
  validate :assert_tenant
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content

  VOTE_OPTIONS = [:pro, :neutral, :con].freeze

  # @return [ActiveRecord::Relation]
  def self.search(q)
    where('lower(motions.title) SIMILAR TO lower(?) OR ' \
            'lower(motions.content) LIKE lower(?)',
          "%#{q}%",
          "%#{q}%")
  end

  def assert_tenant
    return unless parent_model.is_a?(Question) && parent_model.forum_id != forum_id
    errors.add(:forum, I18n.t('activerecord.errors.models.motions.attributes.forum.different'))
  end

  def as_json(options = {})
    super((options || {}).merge(
      methods: %i(display_name),
      only: %i(id content forum_id created_at cover_photo updated_at)
    ))
  end

  def cap_title
    title[0] = title[0].upcase
    title
  end

  def creator
    super || Profile.first_or_create(name: 'Onbekend')
  end

  # http://schema.org/description
  def description
    content
  end

  def display_name
    title
  end

  def move_to(forum, unlink_question = true)
    Motion.transaction do
      self.forum = forum.lock!
      self.question_id = nil if unlink_question
      edge.parent = forum.edge
      save!
      edge.descendants.lock(true).includes(:owner).find_each do |descendant|
        descendant.owner.update_column(:forum_id, forum.id)
      end
      activities.lock(true).update_all forum_id: forum.id
      taggings.lock(true).update_all forum_id: forum.id
      true
    end
  end

  def next(show_trashed = false)
    forum
      .motions
      .show_trashed(show_trashed)
      .where('motions.updated_at < :date',
             date: updated_at)
      .order('motions.updated_at')
      .last
  end

  def previous(show_trashed = false)
    forum
      .motions
      .show_trashed(show_trashed)
      .where('motions.updated_at > :date',
             date: updated_at)
      .order('motions.updated_at')
      .first
  end

  def raw_score
    children_count(:votes_pro) - children_count(:votes_con)
  end

  def score
    number_to_human(raw_score, format: '%n%u', units: {thousand: 'K'})
  end

  def tag_list
    super.join(',')
  end

  def tag_list=(value)
    super value.class == String ? value.downcase.strip : value.collect(&:downcase).collect(&:strip)
  end
end
