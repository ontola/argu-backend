include ActionView::Helpers::NumberHelper

class Motion < ActiveRecord::Base
  include ArguBase, Trashable, Parentable, Convertible, ForumTaggable, Attribution, HasLinks, PublicActivity::Common, Mailable

  has_many :arguments, -> { argument_comments }, :dependent => :destroy
  has_many :opinions, -> { opinion_comments }, :dependent => :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :question_answers, inverse_of: :motion, dependent: :destroy
  has_many :questions, through: :question_answers
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :group_responses
  belongs_to :forum, inverse_of: :motions
  belongs_to :creator, class_name: 'Profile'

  counter_culture :forum

  before_save :trim_data
  before_save :cap_title
  after_save :creator_follow

  parentable :questions, :forum
  convertible :votes, :taggings, :activities
  mailable MotionMailer, :directly, :daily, :weekly
  resourcify
  mount_uploader :cover_photo, CoverUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 110 }
  validates :forum_id, :creator_id, presence: true

  def cap_title
    self.title[0] = self.title[0].upcase
    self.title
  end

  def con_count
    self.arguments.count(:conditions => ['pro = false'])
  end

  def creator
    super || Profile.first_or_create(name: 'Onbekend')
  end

  def creator_follow
    self.creator.follow self
  end

  def display_name
    title
  end

  def invert_arguments
    false
  end

  def invert_arguments=(invert)
    if invert != '0'
      self.arguments.each do |a|
        a.update_attributes pro: !a.pro
      end
    end
  end

  def is_main_motion?(tag)
    self.tags.reject { |a,b| a.motion == b }.first == tag
  end

  def move_to(forum, unlink_questions = true)
    Motion.transaction do
      old_forum = self.forum
      self.forum = forum
      self.save
      self.arguments.update_all forum_id: forum.id
      self.opinions.update_all forum_id: forum.id
      self.votes.update_all forum_id: forum.id
      self.question_answers.delete_all if unlink_questions
      self.activities.update_all forum_id: forum.id
      self.taggings.update_all forum_id: forum.id
      self.group_responses.delete_all
      old_forum.decrement :motions_count
      forum.increment :motions_count
      old_forum.save
      forum.save
    end
    return true
  end

  def next(show_trashed= false)
    self.forum.motions.trashed(show_trashed).where('updated_at < :date', date: self.updated_at).order('updated_at').last
  end

  def previous(show_trashed= false)
    self.forum.motions.trashed(show_trashed).where('updated_at > :date', date: self.updated_at).order('updated_at').first
  end

  def pro_count
    self.arguments.count(:conditions => ['pro = true'])
  end

  def raw_score
    self.votes_pro_count - self.votes_con_count
  end

  def score
    number_to_human(raw_score, :format => '%n%u', :units => { :thousand => 'K' })
  end

  def tag_list
    super.join(',')
  end

  def tag_list=(value)
    super value.class == String ? value.downcase.strip : value.collect(&:downcase).collect(&:strip)
  end

  def top_arguments_con
    self.arguments.where(pro: false).trashed(false).order(votes_pro_count: :desc).limit(5)
  end

  def top_arguments_pro
    self.arguments.where(pro: true).trashed(false).order(votes_pro_count: :desc).limit(5)
  end

  # Same as {Argument#top_arguments_con} but plucks only :id, :title, and :pro
  def top_arguments_con_light
    self.arguments.where(pro: false).trashed(false).order(votes_pro_count: :desc).limit(5).pluck(:id, :title, :pro)
  end

  # Same as {Argument#top_arguments_pro} but plucks only :id, :title, and :pro
  def top_arguments_pro_light
    self.arguments.where(pro: true).trashed(false).order(votes_pro_count: :desc).limit(5).pluck(:id, :title, :pro)
  end

  def total_vote_count
    votes_pro_count.abs + votes_con_count.abs + votes_neutral_count.abs
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def votes_pro_percentage
    if votes_pro_count == 0
      if total_vote_count == 0
        33
      else
        0
      end
    else
      (votes_pro_count.to_f / total_vote_count * 100).round.abs
    end
  end

  def votes_neutral_percentage
    if votes_neutral_count == 0
      if total_vote_count == 0
        33
      else
        0
      end
    else
      (votes_neutral_count.to_f / total_vote_count * 100).round.abs
    end
  end

  def votes_con_percentage
    if votes_con_count == 0
      if total_vote_count == 0
        33
      else
        0
      end
    else
      (votes_con_count.to_f / total_vote_count * 100).round.abs
    end
  end

end
