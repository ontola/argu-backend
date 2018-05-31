# frozen_string_literal: true

class Question < Edge
  include ActivePublishable
  concern Commentable
  include Edgeable::Content
  include HasLinks
  include Attribution
  include BlogPostable
  include Timelineable
  concern Motionable
  include CustomGrants
  include Moveable
  include Photoable

  convertible motions: %i[activities media_objects]
  counter_cache true
  parentable :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  before_save :capitalize_title
  # TODO: validate expires_at

  custom_grants_for :motions, :create

  property :require_location, :boolean, NS::ARGU[:requireLocation], default: false
  property :default_sorting,
           :integer,
           NS::ARGU[:defaultSorting],
           default: 0,
           enum: {popular: 0, created_at: 1, updated_at: 2}

  def expired?
    expires_at.present? && expires_at < Time.current
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

  scope :index, ->(trashed, page) { show_trashed(trashed).page(page) }

  private

  def sister_node(show_trashed)
    parent
      .questions
      .published
      .show_trashed(show_trashed)
      .order('edges.updated_at')
  end
end
