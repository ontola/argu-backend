
class Argument < ActiveRecord::Base
  include ProCon
  scope :argument_comments, -> { includes(:comment_threads).order(votes_pro_count: :desc).references(:comment_threads) }

  def top_comment(show_trashed = nil)
    comments = self.filtered_comments(show_trashed).reject(&:is_trashed)
    root_comments = comments.reject(&:parent_id)
    if root_comments.length > 0
      root_comments.first
    else
      comments.first
    end
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
    _next = self.motion.arguments.trashed(show_trashed).order(votes_pro_count: :desc).limit(50).select(:id, :title).reverse
    _next[((_next.index { |a| a.id == self.id } || 0) + 1) % _next.length]
  end

  def previous(show_trashed = false)
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
                      ["pro = ?", true] => 'argument_pro_count',
                      ["pro = ?", false] => 'argument_con_count'
                  }

end
