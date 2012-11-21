include HasRestfulPermissions

class Statement < ActiveRecord::Base
  has_many :arguments, :dependent => :destroy
  #, order: "pro_count DESC"

  before_save :trim_data
  before_save :cap_title

  has_paper_trail

  attr_accessible :id, :title, :content, :arguments, :statetype, :pro_count, :con_count
 
  validates :content, presence: true, length: { minimum: 5, maximum: 140 }
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }

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

  def trim_data
    self.title = title.strip
    self.content = content.strip
  end

  def cap_title 
    self.title = self.title.capitalize
  end

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
