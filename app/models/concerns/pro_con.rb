module ProCon
  extend ActiveSupport::Concern

  included do
    include ArguBase, Trashable, Parentable, HasLinks, PublicActivity::Common

    belongs_to :motion, touch: true
    has_many :votes, as: :voteable, :dependent => :destroy, inverse_of: :voteable
    has_many :activities, as: :trackable, dependent: :destroy
    belongs_to :creator, class_name: 'Profile'

    before_save :trim_data
    before_save :cap_title
    after_create :creator_follow

    validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
    validates :title, presence: true, length: { minimum: 5, maximum: 75 }
    validates :creator_id, :motion_id, presence: true

    acts_as_commentable
    parentable :motion#, :forum

    #todo: Doesn't seem like a good idea
    #def creator
    #  super || Profile.first_or_create(username: 'Onbekend')
    #end

  end

  def creator_follow
    self.creator.follow self
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
      HashWithIndifferentAccess.new(
          pro: {collection: grouped[:pro] || []},
          con: {collection: grouped[:con] || []})
    end
  end
end
