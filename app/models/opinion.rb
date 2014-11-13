include HasRestfulPermissions

class Opinion < ActiveRecord::Base
  include ProCon

  scope :opinion_comments, -> { includes(:comment_threads).trashed(false).order(votes_pro_count: :desc).references(:comment_threads) }

  counter_culture :statement,
                  column_name: Proc.new { |a| "opinion_#{a.pro? ? 'pro' : 'con'}_count" },
                  column_names: {
                      ["pro = ?", true] => 'opinion_pro_count',
                      ["pro = ?", false] => 'opinion_con_count'
                  }

end
