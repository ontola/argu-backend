include HasRestfulPermissions

class Argument < ActiveRecord::Base
  belongs_to :statement, :dependent => :destroy
  has_many :votes

  before_save :trim_data
  before_save :cap_title

  has_paper_trail
  acts_as_commentable
  acts_as_voteable

  attr_accessible :id, :content, :title, :argtype, :statement, :votes, :pro, :statement_id, :is_trashed

  validates :content, presence: true, length: { minimum: 5, maximum: 1500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }

  def after_save
    self.update_counter_cache
  end

  def after_destroy
    self.update_counter_cache
  end

  def trash
    self.is_trashed = true
    self.save
  end

# Custom methods

  def cap_title 
    self.title = self.title.capitalize
  end

  #TODO escape content=(text)
  def supped_content
    refs = 0
    content.gsub(/(\[\w*\])(\(\w*\))/) {|url,text| '<a class="inlineref" href="#ref%d">%d</a>' % [refs += 1, refs] }
  end

  def references
    refs = 0
    content.scan(/\[(\w*)\]\((\w*)\)/).each { |r| r << 'ref' + (refs += 1).to_s }
  end

  def creator
    User.find_by_id self.versions.first.whodunnit
  end

  def is_moderator?(user)
    self.statement.is_moderator?(user)
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def update_counter_cache
    self.statement.pro_count = self.statement.arguments.count(:conditions => ["pro = true"])
    self.statement.con_count = self.statement.arguments.count(:conditions => ["pro = false"])
    self.statement.save
  end

# Scopes

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
