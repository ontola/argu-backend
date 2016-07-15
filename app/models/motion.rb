# frozen_string_literal: true
include ActionView::Helpers::NumberHelper

class Motion < ActiveRecord::Base
  include ArguBase, Trashable, Parentable, ForumTaggable, Attribution, HasLinks,
          BlogPostable, PublicActivity::Common, Flowable, Placeable, Photoable

  belongs_to :creator, class_name: 'Profile'
  belongs_to :forum, inverse_of: :motions
  belongs_to :project, inverse_of: :motions
  belongs_to :publisher, class_name: 'User'
  belongs_to :question, inverse_of: :motions

  has_many :arguments, -> { argument_comments }, dependent: :destroy
  has_many :top_arguments_con, (lambda do
    argument_comments
      .where(pro: false)
      .trashed(false)
      .order(votes_pro_count: :desc)
      .limit(5)
  end), class_name: 'Argument'
  has_many :top_arguments_pro, (lambda do
    argument_comments
      .where(pro: true)
      .trashed(false)
      .order(votes_pro_count: :desc)
      .limit(5)
  end), class_name: 'Argument'
  has_many :arguments_plain, class_name: 'Argument'
  has_many :group_responses
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  has_many :votes, as: :voteable, dependent: :destroy

  before_save :cap_title

  def self.counter_culture_opts
    {
      column_name: proc { |model| !model.is_trashed? ? 'motions_count' : nil },
      column_names: {
        ['motions.is_trashed = ?', false] => 'motions_count'
      }
    }
  end
  counter_culture :forum, counter_culture_opts
  counter_culture :project, counter_culture_opts
  counter_culture :question, counter_culture_opts
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
    where('lower(motions.title) SIMILAR TO lower(?) OR ' +
            'lower(motions.content) LIKE lower(?)',
          "%#{q}%",
          "%#{q}%")
  end

  def self.published
    joins('LEFT OUTER JOIN projects ON projects.id = project_id')
      .where('is_published = true OR project_id IS NULL')
  end

  # @param [Profile] profile What profile's votes should be included
  def self.votes_for_profile(profile)
    join = "LEFT JOIN votes ON votes.voteable_type = 'Motion'"
    join << " AND votes.voteable_id = motions.id AND votes.voter_type = 'Profile'"
    join << " AND votes.voter_id = #{profile.id}"
    joins(join)
        .references(:votes)
        .select('motions.*,votes.*')
  end

  def assert_tenant
    if question.present? && question.forum_id != forum_id
      errors.add(:forum, I18n.t('activerecord.errors.models.motions.attributes.forum.different'))
    end
  end

  def as_json(options = {})
    super(options.merge(
      methods: %i(display_name),
      only: %i(id content forum_id created_at cover_photo
               updated_at pro_count con_count
               votes_pro_count votes_con_count votes_neutral_count
               argument_pro_count argument_con_count)
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

  def invert_arguments
    false
  end

  def invert_arguments=(invert)
    if invert != '0'
      Motion.transaction do
        arguments.each do |a|
          a.update_attributes pro: !a.pro
        end
      end
    end
  end

  def motions_title
    question.try(:motions_title) || forum.motions_title
  end

  def motions_title_singular
    question.try(:motions_title_singular) || forum.motions_title_singular
  end

  def move_to(forum, unlink_question = true)
    Motion.transaction do
      self.forum = forum.lock!
      self.question_id = nil if unlink_question
      edge.parent = forum.edge
      save
      arguments.lock(true).update_all forum_id: forum.id
      votes.lock(true).update_all forum_id: forum.id
      activities.lock(true).update_all forum_id: forum.id
      taggings.lock(true).update_all forum_id: forum.id
      group_responses.lock(true).delete_all
      true
    end
  end

  def next(show_trashed = false)
    forum
      .motions
      .trashed(show_trashed)
      .where('updated_at < :date',
             date: updated_at)
      .order('updated_at')
      .last
  end

  def previous(show_trashed = false)
    forum
      .motions
      .trashed(show_trashed)
      .where('updated_at > :date',
             date: updated_at)
      .order('updated_at')
      .first
  end

  def raw_score
    votes_pro_count - votes_con_count
  end

  def responses_from(profile, group)
    group_responses.where(creator_id: profile.id, group: group).count
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

  def total_vote_count
    votes_pro_count.abs + votes_con_count.abs + votes_neutral_count.abs
  end

  def update_vote_counters
    vote_counts = votes.group('"for"').count
    update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
           votes_con_count: vote_counts[Vote.fors[:con]] || 0,
           votes_neutral_count: vote_counts[Vote.fors[:neutral]] || 0,
           votes_abstain_count: vote_counts[Vote.fors[:abstain]] || 0
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
