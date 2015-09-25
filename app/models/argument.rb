class Argument < ActiveRecord::Base
  include ProCon
  has_many :subscribers, through: :followings, source: :follower, source_type: 'User'


  scope :argument_comments, -> { includes(:comment_threads).order(votes_pro_count: :desc).references(:comment_threads) }

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
    show_trashed = true if self.is_trashed?
    _next = self.motion.arguments.trashed(show_trashed).order(votes_pro_count: :desc).limit(50).select(:id, :title).reverse
    _next[((_next.index { |a| a.id == self.id } || 0) + 1) % _next.length]
  end

  def previous(show_trashed = false)
    show_trashed = true if self.is_trashed?
    prev = self.motion.arguments.trashed(show_trashed).order(votes_pro_count: :desc).limit(50).select(:id, :title)
    prev[(prev.index { |a| a.id == self.id } + 1) % prev.length]
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
