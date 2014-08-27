include HasRestfulPermissions

class Statement < ActiveRecord::Base
  has_many :arguments, :dependent => :destroy
  has_many :opinions, :dependent => :destroy
  has_many :votes, as: :voteable

  before_save :trim_data
  before_save :cap_title

  acts_as_ordered_taggable_on :tags
  resourcify
  has_paper_trail
 
  validates :content, presence: true, length: { minimum: 5, maximum: 5000 }
  validates :title, presence: true, length: { minimum: 5, maximum: 500 }

  searchable do
    text :title, :content
    text :arguments do
      arguments.map { |argument| argument.content }
    end

    integer :pro_count
    integer :con_count

    string  :sort_title do
      title.downcase.gsub(/^(an?|the)/, '')
    end
  end
  handle_asynchronously :solr_index
  handle_asynchronously :solr_index!
  handle_asynchronously :remove_from_index

# Custom methods

  def cap_title 
    self.title = self.title.capitalize
  end

  def con_count
    self.arguments.count(:conditions => ["pro = false"])
  end

  def creator
    User.find_by_id self.versions.first.whodunnit
  end

  def is_main_statement?(tag)
    self.tags.reject { |a,b| a.statement == b }.first == tag
  end

  def pro_count
    self.arguments.count(:conditions => ["pro = true"])
  end

  def supped_content
    content \
      .gsub(/{([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)}\(([\w\s]*)\)/, '<a rel=tag name="\1" href="/cards/\1">\2</a>') \
      .gsub(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/, '<a href="\1">\2</a>')
  end

  def trash
    update_column :is_trashed, true
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

  scope :index, ->(trashed, page) { where(is_trashed: trashed.present?).order('pro_count + con_count DESC').page(page) }
end
