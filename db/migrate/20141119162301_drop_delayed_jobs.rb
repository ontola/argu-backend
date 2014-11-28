class DropDelayedJobs < ActiveRecord::Migration
  def change
    drop_table :delayed_jobs
    drop_table :follows
  end
end
