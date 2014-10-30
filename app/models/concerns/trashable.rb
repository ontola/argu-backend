module ProCon
  extend ActiveSupport::Concern

  included do
    belongs_to :statement, :dependent => :destroy
    has_many :votes, as: :voteable
    belongs_to :creator, class_name: 'User'

    before_save :trim_data
    before_save :cap_title

    validates :content, presence: true, length: { minimum: 5, maximum: 1500 }
    validates :title, presence: true, length: { minimum: 5, maximum: 75 }

    acts_as_commentable

    def creator
      super || User.new(username: 'Onbekend')
    end
  end

  def trash
    update_column :is_trashed, true
  end

  # To facilitate the group_by command
  def key
    self.pro ? :pro : :con
  end

  def trim_data
    self.title = title.strip
    self.content = content.strip
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

  def root_comments
    self.comment_threads.where(:parent_id => nil)
  end

  def is_moderator?(user)
    self.statement.is_moderator?(user)
  end

  def cap_title
    self.title = self.title.capitalize
  end

  module ClassMethods

  end
end
