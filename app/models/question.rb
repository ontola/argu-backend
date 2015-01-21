class Question < ActiveRecord::Base
  include ArguBase, Trashable, Parentable, Convertible, ForumTaggable, Attribution

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  has_many :question_answers, inverse_of: :question, dependent: :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :motions, through: :question_answers

  counter_culture :forum
  parentable :forum
  convertible :votes, :taggings
  mount_uploader :cover_photo, CoverUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :forum_id, :creator_id, presence: true

  attr_accessor :include_motions

  def creator
    super || Profile.first_or_create(username: 'Onbekend')
  end

  def display_name
    title
  end

  def move_to(forum, include_motions = false)
    ActiveRecord::Base.transaction do
      old_forum = self.forum
      self.forum = forum
      self.save
      self.votes.update_all forum_id: forum.id
      if include_motions
        self.motions.each do |m|
          m.move_to forum, false
        end
      else
        self.question_answers.delete_all
      end
      old_forum.decrement :questions_count
      forum.increment :questions_count
    end
    return true
  end

  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/, '<a href="\1">\2</a>')
  end

  def tag_list
    super.join(',')
  end

  scope :index, ->(trashed, page) { trashed(trashed).page(page) }
end