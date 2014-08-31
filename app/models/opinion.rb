include HasRestfulPermissions

class Opinion < ActiveRecord::Base
  belongs_to :statement, :dependent => :destroy
  has_many :votes, as: :voteable
  default_scope { includes(:comment_threads).where(is_trashed: false).order(votes_pro_count: :desc) }

  counter_culture :statement,
                  column_names: {
                      ["pro = ?", true] => 'opinion_pro_count',
                      ["pro = ?", false] => 'opinion_con_count'
                  }

  before_save :trim_data
  before_save :cap_title

  has_paper_trail
  acts_as_commentable

  validates :content, presence: true, length: { minimum: 5, maximum: 1500 }
  validates :title, presence: true, length: { minimum: 5, maximum: 75 }

  def after_save
    self.update_counter_cache
  end

  def after_destroy
    self.update_counter_cache
  end

  def trash
    update_column :is_trashed, true
  end

  # To facilitate the group_by command
  def key
  	self.pro ? :pro : :con
  end

# Custom methods

  def cap_title 
    self.title = self.title.capitalize
  end

  #TODO escape content=(text)
  def supped_content
    refs = 0
    content.gsub(/(\[[\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*\])(\([\w\s]*\))/) {|url,text| '<a class="inlineref" href="%s#ref%d">%d</a>' % [Rails.application.routes.url_helpers.argument_path(self), refs += 1, refs] }
  end

  def references
    refs = 0
    content.scan(/\[([\w\\\/\:\?\&\%\_\=\.\+\-\,\#]*)\]\(([\w\s]*)\)/).each { |r| r << 'ref' + (refs += 1).to_s }
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

  def votes_count
    ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM
    (SELECT DISTINCT voter_id, voter_type, avotes.for
    FROM   avotes
    WHERE voteable_type = 'Argument' AND voteable_id = #{self.id}
    GROUP BY voter_id, voter_type, avotes.for) tot WHERE tot.for = 1")[0]['count']
  end

# Scopes

  scope :today, lambda { 
    {
      :conditions => ["created_at >= ?", (Time.now - 1.days)]
    }
  }
end
