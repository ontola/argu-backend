# frozen_string_literal: true

class Question < Edgeable::Base
  include ActivePublishable
  include Attachable
  include Commentable
  include ContentEdgeable
  include HasLinks
  include Attribution
  include Convertible
  include BlogPostable
  include Timelineable
  include Photoable
  include Motionable
  include CustomGrants

  has_many :votes, as: :voteable, dependent: :destroy
  has_many :motions, dependent: :nullify

  convertible motions: %i[activities blog_posts media_objects]
  counter_cache true
  parentable :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :forum, :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  # TODO: validate expires_at

  enum default_sorting: {popular: 0, created_at: 1, updated_at: 2}
  attr_accessor :include_motions

  custom_grants_for :motions, :create

  # Might not be a good idea
  def creator
    super || Profile.community
  end

  def display_name
    title
  end

  # http://schema.org/description
  def description
    content
  end

  def self.edge_includes_for_index
    super.deep_merge(active_motions: {})
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def move_to(forum, include_motions = false)
    Question.transaction do
      self.forum = forum.lock!
      edge.parent = forum.edge
      save!
      votes.lock(true).update_all forum_id: forum.id
      activities.lock(true).update_all(forum_id: forum.id, recipient_id: forum.id, recipient_type: 'Forum')
      if include_motions
        motions.lock(true).each do |m|
          m.move_to forum, false
        end
      else
        motions.each do |motion|
          motion.edge.update!(parent: motion.forum.edge)
          motion.update!(question_id: nil)
        end
      end
    end
    true
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

  def question_answers
    QuestionAnswer
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
