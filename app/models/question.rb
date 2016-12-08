# frozen_string_literal: true
class Question < ApplicationRecord
  include Trashable, Parentable, ForumTaggable, HasLinks, Attribution, Convertible, Loggable,
          BlogPostable, Timelineable, PublicActivity::Common, Flowable, Placeable, Photoable

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  belongs_to :project, inverse_of: :questions
  belongs_to :publisher, class_name: 'User'
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :motions, dependent: :nullify, inverse_of: :question
  has_many :top_motions, -> { untrashed.order(updated_at: :desc) }, class_name: 'Motion'
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'

  convertible motions: %i(votes taggings activities)
  counter_cache true
  parentable :project, :forum

  validates :content, presence: true, length: {minimum: 5, maximum: 5000}
  validates :title, presence: true, length: {minimum: 5, maximum: 110}
  validates :forum, :creator, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  # TODO: validate expires_at

  attr_accessor :include_motions

  # Might not be a good idea
  def creator
    super || Profile.first_or_initialize(shortname: 'Onbekend')
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
      save
      votes.lock(true).update_all forum_id: forum.id
      activities.lock(true).update_all forum_id: forum.id
      if include_motions
        motions.lock(true).each do |m|
          m.move_to forum, false
        end
      else
        motions.each do |motion|
          motion.update(question: nil)
          motion.edge.update(parent: motion.forum.edge)
        end
      end
    end
    true
  end

  def next(show_trashed = false)
    forum
      .questions
      .show_trashed(show_trashed)
      .where('questions.updated_at < :date', date: updated_at)
      .order('questions.updated_at')
      .last
  end

  def previous(show_trashed = false)
    forum
      .questions
      .show_trashed(show_trashed)
      .where('questions.updated_at > :date', date: updated_at)
      .order('questions.updated_at')
      .first
  end

  def question_answers
    QuestionAnswer
  end

  def tag_list
    super.join(',')
  end

  scope :index, ->(trashed, page) { show_trashed(trashed).page(page) }
end
