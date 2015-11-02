module ProCon
  extend ActiveSupport::Concern

  VOTE_OPTIONS = [:pro]

  included do
    include ArguBase, Trashable, Parentable, HasLinks, PublicActivity::Common

    belongs_to :motion, touch: true
    has_many :votes, as: :voteable, :dependent => :destroy, inverse_of: :voteable
    has_many :activities, as: :trackable, dependent: :destroy
    belongs_to :creator, class_name: 'Profile'
    belongs_to :forum

    before_save :cap_title
    after_create :creator_follow, :update_vote_counters

    validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
    validates :title, presence: true, length: { minimum: 5, maximum: 75 }
    validates :creator, :motion, :forum, presence: true
    auto_strip_attributes :title, squish: true
    auto_strip_attributes :content

    acts_as_commentable
    acts_as_followable
    parentable :motion, :forum

    delegate :uses_alternative_names, :motions_title, :motions_title_singular, to: :motion
  end

  def creator_follow
    if self.creator.profileable.is_a?(User)
      self.creator.profileable.follow self
    end
  end

  def cap_title
    self.title[0] = self.title[0].upcase
    self.title
  end

  def display_name
    title
  end

  # To facilitate the group_by command
  def key
    self.pro ? :pro : :con
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def pro=(value)
    value = false if value.to_s == 'con'
    super value.to_s == 'pro' || value
  end

  def root_comments
    self.comment_threads.where(is_trashed: false, :parent_id => nil)
  end

  def update_vote_counters
    vote_counts = self.votes.group('"for"').count
    self.update votes_pro_count: vote_counts[Vote.fors[:pro]] || 0,
                votes_con_count: vote_counts[Vote.fors[:con]] || 0,
                votes_abstain_count: vote_counts[Vote.fors[:abstain]] || 0
  end

  module ClassMethods
    def ordered (coll=[])
      grouped = coll.group_by { |a| a.key }
      HashWithIndifferentAccess.new(pro: {collection: grouped[:pro]}, con: {collection: grouped[:con]})
    end
  end
end
