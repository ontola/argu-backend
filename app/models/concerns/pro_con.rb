module ProCon
  extend ActiveSupport::Concern

  included do
    include ArguBase, Trashable, Parentable, HasReferences, PublicActivity::Common

    belongs_to :motion, touch: true
    has_many :votes, as: :voteable, :dependent => :destroy
    has_many :activities, as: :trackable, dependent: :destroy
    belongs_to :creator, class_name: 'Profile'
    belongs_to :forum

    before_save :trim_data
    before_save :cap_title

    validates :content, presence: true, length: { minimum: 5, maximum: 3000 }
    validates :title, presence: true, length: { minimum: 5, maximum: 75 }
    validates :creator_id, :motion_id, :forum_id, presence: true

    acts_as_commentable
    parentable :motion, :forum

    def creator
      super || Profile.first_or_create(username: 'Onbekend')
    end

  end

  def cap_title
    self.title[0] = self.title[0].upcase
    self.title
  end

  def collect_recipients(type)
    #profiles.merge forum.followers_by_type('Profile').joins('LEFT OUTER JOIN users ON users.profile_id = profiles.id').where(users: {memberships_email: User.memberships_emails[:direct_memberships_email]})
    profiles = Set.new
    if type == :directly
      profiles.merge creator if commentable.creator.owner.direct_created_email?
      profiles.merge commentable.parent.creator if comment.parent && comment.parent.creator.owner.direct_created_email?
    end
  end

  def display_name
    title
  end

  # To facilitate the group_by command
  def key
    self.pro ? :pro : :con
  end

  def next
    #TODO Improve these functions. Currently, it seems that the order is not maintained.
    _next = self.motion.arguments.where(is_trashed: false).order(votes_pro_count: :asc).reverse_order.select(:id, :title).to_a
    _next[(_next.index { |a| a.id == self.id } + 1) % _next.length]
  end

  def previous
    prev = self.motion.arguments.where(is_trashed: false).order(votes_pro_count: :desc).select(:id, :title).to_a
    prev[(prev.index { |a| a.id == self.id } + 1) % prev.length]
  end

  def pro=(value)
    super value.to_s == 'pro' || value
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def root_comments
    self.comment_threads.where(is_trashed: false, :parent_id => nil)
  end

  module ClassMethods
    def ordered (coll=[])
      grouped = coll.group_by { |a| a.key }
      HashWithIndifferentAccess.new(pro: {collection: grouped[:pro]}, con: {collection: grouped[:con]})
    end
  end
end
