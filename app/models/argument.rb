class Argument < ActiveRecord::Base
  include ProCon, Flowable
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'
  belongs_to :publisher, class_name: 'User'

  validate :assert_tenant

  scope :argument_comments, -> { includes(:comment_threads).order(votes_pro_count: :desc).references(:comment_threads) }

  def assert_tenant
    if self.forum != self.motion.forum
      errors.add(:forum, I18n.t('activerecord.errors.models.arguments.attributes.forum.different'))
    end
  end

  # http://schema.org/description
  def description
    self.content
  end

  def top_comment(show_trashed = nil)
    comment_threads.where(parent_id: nil, is_trashed: false).order('created_at ASC').first
  end

  def filtered_threads(show_trashed = nil, page = nil, order = 'created_at ASC')
    i = comment_threads.where(:parent_id => nil).order(order).page(page)
    i.each(&wipe) unless show_trashed
    i
  end

  def filtered_comments(show_trashed = nil, page = nil, order = 'created_at ASC')
    i = comment_threads.order(order).page(page)
    i.each(&wipe) unless show_trashed
    i
  end

  def next(show_trashed = false)
    adjacent(false, show_trashed)
  end

  # @return [TODO, nil] The id of the previous item or nil.
  def previous(show_trashed = false)
    adjacent(true, show_trashed)
  end

  def adjacent(direction, show_trashed = nil)
    ids = self.motion.arguments_plain.order(votes_pro_count: :desc).ids
    index = ids.index(self[:id])
    return nil if ids.length < 2
    p_id = ids[index.send(direction ? :- : :+, 1) % ids.count]
    self.motion.arguments.find_by(id: p_id)
  end

  def wipe
    Proc.new do |c|
      if c.is_trashed?
        c.body= '[DELETED]'
        c.profile = nil
        c.is_processed = true
      end
      if c.children.present?
        c.children.each(&wipe);
      end
    end
  end

  counter_culture :motion,
                  column_name: Proc.new { |a| a.is_trashed ? nil : "argument_#{a.pro? ? 'pro' : 'con'}_count" },
                  column_names: {
                      ['pro = ?', true] => 'argument_pro_count',
                      ['pro = ?', false] => 'argument_con_count'
                  }
end
