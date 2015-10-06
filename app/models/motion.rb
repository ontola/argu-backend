include ActionView::Helpers::NumberHelper

class Motion < ActiveRecord::Base
  include ArguBase, Trashable, Parentable, Convertible, ForumTaggable, Attribution, HasLinks,
          PublicActivity::Common, Flowable, Placeable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :forum, inverse_of: :motions
  belongs_to :project, inverse_of: :motions
  belongs_to :publisher, class_name: 'User'
  belongs_to :question, inverse_of: :motions

  has_many :activities, as: :trackable, dependent: :destroy
  has_many :arguments, -> { argument_comments }, dependent: :destroy
  has_many :group_responses
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  has_many :votes, as: :voteable, dependent: :destroy

  before_save :cap_title
  after_save :creator_follow

  counter_culture :forum
  acts_as_followable
  parentable :question, :project, :forum
  convertible :votes, :taggings, :activities
  resourcify
  mount_uploader :cover_photo, CoverUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 110 }
  validates :forum, :creator, presence: true
  validate :assert_tenant
  auto_strip_attributes :title, squish: true
  auto_strip_attributes :content

  VOTE_OPTIONS = [:pro, :neutral, :con]

  scope :search, ->(q) { where('lower(title) SIMILAR TO lower(?) OR ' +
                                'lower(content) LIKE lower(?)',
                                "%#{q}%",
                                "%#{q}%") }

  scope :published, -> do
    joins('LEFT OUTER JOIN projects ON projects.id = project_id')
      .where('published_at IS NOT NULL OR project_id IS NULL')
  end

  def assert_tenant
    if self.question.present? && self.question.forum_id != self.forum_id
      errors.add(:forum, I18n.t('activerecord.errors.models.motions.attributes.forum.different'))
    end
  end

  def as_json(options = {})
    super(options.merge(
              {
                  methods: %i(display_name),
                  only: %i(id content forum_id created_at cover_photo
                           updated_at pro_count con_count
                           votes_pro_count votes_con_count votes_neutral_count
                           argument_pro_count argument_con_count)
              }))
  end

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
    if self.creator.profileable.is_a?(User)
      self.creator.profileable.follow self
    end
  end

  # http://schema.org/description
  def description
    self.content
  end

  def display_name
    title
  end

  def invert_arguments
    false
  end

  def invert_arguments=(invert)
    if invert != '0'
      Motion.transaction do
        self.arguments.each do |a|
          a.update_attributes pro: !a.pro
        end
      end
    end
  end

  def motions_title
    self.question.try(:motions_title) ||
      self.forum.motions_title
  end

  def motions_title_singular
    self.question.try(:motions_title_singular) ||
      self.forum.motions_title_singular
  end

  def move_to(forum, unlink_question = true)
    Motion.transaction do
      old_forum = self.forum.lock!
      self.forum = forum.lock!
      self.question_id = nil if unlink_question
      self.save
      self.arguments.lock(true).update_all forum_id: forum.id
      self.votes.lock(true).update_all forum_id: forum.id
      self.activities.lock(true).update_all forum_id: forum.id
      self.taggings.lock(true).update_all forum_id: forum.id
      self.group_responses.lock(true).delete_all

      old_forum.decrement :motions_count
      old_forum.save

      forum.increment :motions_count
      forum.save
      true
    end
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

  def responses_from(profile, group)
    self.group_responses.where(profile_id: profile.id, group: group).count
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

  # Same as {Argument#top_arguments_con} but plucks only :id, :title, :pro, and :votes_pro_count
  def top_arguments_con_light
    self.arguments.where(pro: false).trashed(false).order(votes_pro_count: :desc).uniq.limit(5).pluck(:id, :title, :pro, :votes_pro_count, :content, :comments_count)
  end

  # Same as {Argument#top_arguments_pro} but plucks only :id, :title, :pro, and :votes_pro_count
  def top_arguments_pro_light
    self.arguments.where(pro: true).trashed(false).order(votes_pro_count: :desc).uniq.limit(5).pluck(:id, :title, :pro, :votes_pro_count, :content, :comments_count)
  end

  def total_vote_count
    votes_pro_count.abs + votes_con_count.abs + votes_neutral_count.abs
  end

  def update_vote_counters
    vote_counts = self.votes.group('"for"').count
    self.update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
                votes_con_count: vote_counts[Vote.fors[:con]] || 0,
                votes_neutral_count: vote_counts[Vote.fors[:neutral]] || 0,
                votes_abstain_count: vote_counts[Vote.fors[:abstain]] || 0
  end

  def uses_alternative_names
    self.question.try(:uses_alternative_names) ||
      self.forum.uses_alternative_names
  end

  def votes_pro_percentage
    vote_percentage votes_pro_count
  end

  def votes_neutral_percentage
    vote_percentage votes_neutral_count
  end

  def votes_con_percentage
    vote_percentage votes_con_count
  end

  def vote_percentage(vote_count)
    if vote_count == 0
      if total_vote_count == 0
        33
      else
        0
      end
    else
      (vote_count.to_f / total_vote_count * 100).round.abs
    end
  end

end
