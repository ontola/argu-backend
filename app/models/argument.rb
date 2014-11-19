include HasRestfulPermissions              # This seems superfluous

class Argument < ActiveRecord::Base
  include ProCon
  scope :argument_comments, -> { includes(:comment_threads).trashed(false).order(votes_pro_count: :desc).references(:comment_threads) }

  counter_culture :motion,
                  column_name: Proc.new { |a| a.is_trashed ? nil : "argument_#{a.pro? ? 'pro' : 'con'}_count" },
                  column_names: {
                      ["pro = ?", true] => 'argument_pro_count',
                      ["pro = ?", false] => 'argument_con_count'
                  }

end
