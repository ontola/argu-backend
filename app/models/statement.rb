include HasRestfulPermissions

class Statement < ActiveRecord::Base
  has_many :arguments, :dependent => :destroy
  #, order: "pro_count DESC"

  before_save :trim_data
  before_save :cap_title

  acts_as_ordered_taggable_on :tags

  has_paper_trail

  attr_accessible :id, :title, :content, :arguments, :statetype, :pro_count, :con_count, :moderators, :tag_list, :invert_arguments, :tag_id
 
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

  def is_moderator?(user)
    self.mods.include?(user.id)
  end

  def mods
    if !self.moderators.blank?
      return self.moderators.split(',').map { |s| s.to_i }
    else 
      return []
    end
  end

  def add_mod(user)
    self.mods << user.id unless self.mods.include? user.id
  end

  def pro_count
    self.arguments.count(:conditions => ["pro = true"])
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def invert_arguments
    false
  end

  def invert_arguments=(invert)
    if invert
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
end
