include ActionView::Helpers::NumberHelper

class Motion < Argu::Base
  include Trashable, Parentable, Convertible, ForumTaggable, Attribution, HasLinks, PublicActivity::Common, Mailable
  extend Argu::TenantUtilities

  has_many :arguments, -> { argument_comments }, :dependent => :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :question_answers, inverse_of: :motion, dependent: :destroy
  has_many :questions, through: :question_answers
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :group_responses
  belongs_to :forum, inverse_of: :motions
  belongs_to :creator, class_name: 'Profile'

  attr_accessor :vote

  before_save :trim_data
  before_save :cap_title
  after_save :creator_follow

  counter_culture :forum
  parentable :questions, :forum
  convertible :votes, :taggings, :activities
  mailable MotionFollowerCollector, :directly, :daily, :weekly
  resourcify
  mount_uploader :cover_photo, CoverUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 110 }
  validates :creator_id, presence: true

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

  def move_to(forum)
    Motion.transaction do
      old_forum = self.forum.lock!
      self.forum = forum.lock!
      self.save
      self.arguments.lock(true).update_all forum_id: forum.id
      self.votes.lock(true).update_all forum_id: forum.id
      self.question_answers.lock(true).delete_all
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

  def self.cascaded_move_sql(ids, old_tenant, new_tenant)
    sql = ''
    Motion.where(id: ids).lock(true).find_each do |subject|
      arguments_ids = subject.arguments.pluck(:id)
      votes_ids = subject.votes.pluck(:id)
      activities_ids = subject.activities.pluck(:id)
      taggings_ids = subject.taggings.pluck(:id)

      sql << "DELETE FROM #{self.class_name} WHERE id IN (#{subject.question_answers.pluck(:id)}); "
      sql << "DELETE FROM #{self.class_name} WHERE id IN (#{subject.group_responses.pluck(:id)}); "

      sql << migration_base_sql(subject.class, new_tenant, old_tenant) +
                "where id = #{subject.id}; "

      sql << Argument.cascaded_move_sql(arguments_ids, old_tenant, new_tenant) if arguments_ids.present?
      sql << Vote.cascaded_move_sql(votes_ids, old_tenant, new_tenant) if votes_ids.present?
      sql << Activity.cascaded_move_sql(activities_ids, old_tenant, new_tenant) if activities_ids.present?
      #sql << Tagging.cascaded_move(taggings_ids, old_tenant, new_tenant) if taggings_ids.present?
    end
    sql
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

  def responses_from(profile)
    self.group_responses.where(profile_id: profile.id).count
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
    self.arguments.where(pro: false).trashed(false).order(votes_pro_count: :desc).uniq.limit(5).pluck(:id, :title, :pro, :votes_pro_count, :content)
  end

  # Same as {Argument#top_arguments_pro} but plucks only :id, :title, :pro, and :votes_pro_count
  def top_arguments_pro_light
    self.arguments.where(pro: true).trashed(false).order(votes_pro_count: :desc).uniq.limit(5).pluck(:id, :title, :pro, :votes_pro_count, :content)
  end

  def total_vote_count
    votes_pro_count.abs + votes_con_count.abs + votes_neutral_count.abs
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
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
