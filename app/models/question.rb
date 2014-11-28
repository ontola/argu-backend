class Question < ActiveRecord::Base
  include Trashable
  include Parentable

  belongs_to :forum, inverse_of: :questions
  belongs_to :creator, class_name: 'Profile'
  has_many :question_answers, inverse_of: :question
  has_many :motions, through: :question_answers

  acts_as_ordered_taggable_on :tags
  parentable :forum

  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :forum_id, :creator_id, presence: true

  def creator
    super || User.first_or_create(username: 'Onbekend')
  end

  def display_name
    title
  end

  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/, '<a href="\1">\2</a>')
  end

  scope :index, ->(trashed, page) { trashed(trashed).page(page) }
end