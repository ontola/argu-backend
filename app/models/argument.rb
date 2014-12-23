include HasRestfulPermissions              # This seems superfluous

class Argument < ActiveRecord::Base
  include ProCon
  scope :argument_comments, -> { includes(:comment_threads).order(votes_pro_count: :desc).references(:comment_threads) }

  def top_comment(show_trashed = nil)
    self.filtered_threads(show_trashed).first
  end

  def filtered_threads(show_trashed = nil, page = nil, order = 'created_at ASC')
    i = comment_threads(show_trashed).where(:parent_id => nil).order(order).page(page)
    i.each(&wipe) unless show_trashed
    i
  end

  def wipe
    Proc.new do |c|
      if c.is_trashed?
        c.body= I18n.t('deleted')
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
