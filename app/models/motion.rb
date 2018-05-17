# frozen_string_literal: true

class Motion < EdgeableBase
  include ActionView::Helpers::NumberHelper
  include ActivePublishable
  concern Argumentable
  include Attachable
  include Photoable
  concern Commentable
  include ContentEdgeable
  include Voteable
  include Attribution
  include HasLinks

  include BlogPostable
  include Timelineable

  include Decisionable

  attr_accessor :current_vote

  alias_attribute :description, :content
  alias_attribute :display_name, :title

  before_save :capitalize_title

  convertible questions: %i[activities media_objects], comments: %i[activities]
  counter_cache true
  paginates_per 30
  parentable :question, :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content

  VOTE_OPTIONS = %i[pro neutral con].freeze unless defined?(VOTE_OPTIONS)

  def as_json(options = {})
    super((options || {}).merge(
      methods: %i[display_name],
      only: %i[id content forum_id created_at cover_photo updated_at]
    ))
  end

  def creator
    super || Profile.community
  end

  def self.edge_includes_for_index(full = false)
    includes = super().deep_merge(default_vote_event: {}, last_published_decision: {})
    return includes unless full
    includes.deep_merge(
      owner: {attachments: {}, creator: Profile.includes_for_profileable}
    )
  end

  def next(show_trashed = false)
    sister_node(show_trashed)
      .where('edges.updated_at < :date', date: updated_at)
      .last
  end

  def previous(show_trashed = false)
    sister_node(show_trashed)
      .find_by('edges.updated_at > :date', date: updated_at)
  end

  def raw_score
    children_count(:votes_pro) - children_count(:votes_con)
  end

  def score
    number_to_human(raw_score, format: '%n%u', units: {thousand: 'K'})
  end

  private

  def sister_node(show_trashed)
    parent_edge
      .motions
      .published
      .show_trashed(show_trashed)
      .order('edges.updated_at')
  end
end
