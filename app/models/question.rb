class Question < ActiveRecord::Base
  include ArguBase
  include Trashable
  include Parentable
  include ForumTaggable

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  has_many :question_answers, inverse_of: :question, dependent: :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :motions, through: :question_answers

  counter_culture :forum
  parentable :forum
  mount_uploader :cover_photo, ImageUploader

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :forum_id, :creator_id, presence: true

  def creator
    super || Profile.first_or_create(username: 'Onbekend')
  end

  def display_name
    title
  end


  #def save_taggings
  #  self.taggings.save
  #end

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