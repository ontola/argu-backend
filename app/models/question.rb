class Question < ActiveRecord::Base
  include ArguBase, Trashable, Parentable, Convertible, ForumTaggable, HasLinks, Attribution, PublicActivity::Common

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  has_many :question_answers, inverse_of: :question, dependent: :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :motions, through: :question_answers
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'

  acts_as_followable
  counter_culture :forum
  parentable :forum
  convertible :votes, :taggings, :activities
  mount_uploader :cover_photo, CoverUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 110 }
  validates :forum_id, :creator_id, presence: true
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content
  #TODO validate expires_at

  attr_accessor :include_motions

  after_save :creator_follow

  # Might not be a good idea
  def creator
    super || Profile.first_or_initialize(shortname: 'Onbekend')
  end

  def creator_follow
    if self.creator.profileable.is_a?(User)
      self.creator.profileable.follow self
    end
  end

  def display_name
    title
  end

  # http://schema.org/description
  def description
    self.content
  end

  def move_to(forum, include_motions = false)
    Question.transaction do
      old_forum = self.forum.lock!
      self.forum = forum.lock!
      self.save
      self.votes.lock(true).update_all forum_id: forum.id
      self.activities.lock(true).update_all forum_id: forum.id
      if include_motions
        self.motions.lock(true).each do |m|
          m.move_to forum, false
        end
      else
        self.question_answers.lock(true).delete_all
      end
      old_forum.reload.decrement :questions_count
      old_forum.save
      forum.reload.increment :questions_count
      forum.save
    end
    true
  end

  def next(show_trashed = false)
    self.forum.questions.trashed(show_trashed).where('updated_at < :date', date: self.updated_at).order('updated_at').last
  end

  def previous(show_trashed = false)
    self.forum.questions.trashed(show_trashed).where('updated_at > :date', date: self.updated_at).order('updated_at').first
  end

  def tag_list
    super.join(',')
  end

  def top_motions
    motions.trashed(false).order(updated_at: :desc).limit(3)
  end

  def update_vote_counters
    vote_counts = self.votes.group('"for"').count
    self.update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
                votes_con_count: vote_counts[Vote.fors[:con]] || 0
  end

  scope :index, ->(trashed, page) { trashed(trashed).page(page) }
end
