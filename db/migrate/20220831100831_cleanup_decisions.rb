class CleanupDecisions < ActiveRecord::Migration[7.0]
  def change
    Decision.find_each { |b| b.update(owner_type: 'BlogPost') }
  end
end
