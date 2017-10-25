class FixOpinionCounts < ActiveRecord::Migration[5.1]
  def change
    Vote.fix_counts
  end
end
