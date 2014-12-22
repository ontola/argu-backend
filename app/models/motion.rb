include HasRestfulPermissions
include ActionView::Helpers::NumberHelper

class Motion < ActiveRecord::Base
  include ArguBase
  include Trashable
  include Parentable
  include ForumTaggable

  has_many :arguments, -> { argument_comments }, :dependent => :destroy
  has_many :opinions, -> { opinion_comments }, :dependent => :destroy
  has_many :votes, as: :voteable, :dependent => :destroy
  has_many :question_answers, inverse_of: :motion, dependent: :destroy
  has_many :questions, through: :question_answers
  belongs_to :forum, inverse_of: :motions
  belongs_to :creator, class_name: 'Profile'

  counter_culture :forum

  before_save :trim_data
  before_save :cap_title

  parentable :questions, :forum
  resourcify
  mount_uploader :cover_photo, ImageUploader
 
  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 500 }
  validates :forum_id, :creator_id, presence: true

# Custom methods

  def cap_title 
    self.title = self.title.capitalize
  end

  def con_count
    self.arguments.count(:conditions => ["pro = false"])
  end

  def creator
    super || Profile.first_or_create(name: 'Onbekend')
  end

  def display_name
    title
  end

  def is_main_motion?(tag)
    self.tags.reject { |a,b| a.motion == b }.first == tag
  end

  def pro_count
    self.arguments.count(:conditions => ["pro = true"])
  end

  def raw_score
    # Neutral voters dont influence the relative score, but they do fluff it
    self.votes_pro_count*self.votes_neutral_count - self.votes_con_count*self.votes_neutral_count
  end

  def score
    number_to_human(raw_score, :format => '%n%u', :units => { :thousand => 'K' })
  end

  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/, '<a href="\1">\2</a>')
  end

  def tag_list
    super.join(',')
  end

  def tag_list=(value)
    super value.class == String ? value.downcase.strip : value.collect(&:downcase).collect(&:strip)
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def invert_arguments
    false
  end

  def invert_arguments=(invert)
    if invert != "0"
      self.arguments.each do |a|
        a.update_attributes pro: !a.pro
      end
    end
  end

# Scopes

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }

  scope :index, ->(trashed, page) { trashed(trashed).order('argument_pro_count + argument_con_count DESC').page(page) }
end
