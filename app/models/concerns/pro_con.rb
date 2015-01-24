module ProCon
  extend ActiveSupport::Concern

  included do
    include ArguBase, Trashable, Parentable, HasReferences, PublicActivity::Common

    belongs_to :motion
    has_many :votes, as: :voteable, :dependent => :destroy
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

  def display_name
    title
  end

  # To facilitate the group_by command
  def key
    self.pro ? :pro : :con
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
