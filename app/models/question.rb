# frozen_string_literal: true
class Question < ApplicationRecord
  include Trashable, Attachable, Commentable, Edgeable, HasLinks, Attribution, Convertible, Loggable,
          BlogPostable, Timelineable, PublicActivity::Common, Placeable, Photoable,
          ActivePublishable, Motionable, Ldable

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :motions, dependent: :nullify
  has_many :top_motions, -> { published.untrashed.order(updated_at: :desc) }, class_name: 'Motion'
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'

  with_collection :motions, pagination: true, url_constructor: :question_canonical_motions_url

  convertible motions: %i(activities blog_posts)
  counter_cache true
  parentable :project, :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :forum, :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  # TODO: validate expires_at

  contextualize_as_type 'argu:Question'
  contextualize_with_id { |m| Rails.application.routes.url_helpers.question_url(m, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :content, as: 'schema:text'

  attr_accessor :include_motions

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

  def expired?
    expires_at.present? && expires_at < DateTime.current
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

  def tag_list
    super.join(',')
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
