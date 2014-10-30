class Question < ActiveRecord::Base
  include Trashable
  belongs_to :organisation
  belongs_to :creator, class_name: 'User'
  has_many :question_answers, inverse_of: :question
  has_many :statements, through: :question_answers

  acts_as_ordered_taggable_on :tags

  def creator
    super || User.first_or_create(username: 'Onbekend')
  end

  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/, '<a href="\1">\2</a>')
  end

  scope :index, ->(trashed, page) { trashed(trashed).page(page) }
end
