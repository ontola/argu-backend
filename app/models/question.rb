# frozen_string_literal: true

class Question < EdgeableBase
  include ActivePublishable
  include Attachable
  concern Commentable
  include ContentEdgeable
  include HasLinks
  include Attribution
  include Convertible
  include BlogPostable
  include Timelineable
  include Photoable
  concern Motionable
  include CustomGrants

  has_many :votes, as: :voteable, dependent: :destroy
  has_many :motions, dependent: :nullify

  convertible motions: %i[activities blog_posts media_objects comment_threads]
  counter_cache true
  parentable :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :forum, :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  # TODO: validate expires_at

  enum default_sorting: {popular: 0, created_at: 1, updated_at: 2}

  alias_attribute :display_name, :title
  alias_attribute :description, :content

  custom_grants_for :motions, :create

  # Might not be a good idea
  def creator
    super || Profile.community
  end

  def self.edge_includes_for_index
    super.deep_merge(active_motions: {})
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def next(show_trashed = false)
    sister_node(show_trashed)
      .where('questions.updated_at < :date', date: updated_at)
      .last
  end

  def previous(show_trashed = false)
    sister_node(show_trashed)
      .find_by('questions.updated_at > :date', date: updated_at)
  end

  scope :index, ->(trashed, page) { show_trashed(trashed).page(page) }

  private

  def sister_node(show_trashed)
    forum
      .questions
      .published
      .show_trashed(show_trashed)
      .order('questions.updated_at')
  end
end
