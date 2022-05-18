class MigrateToDoSpace < ActiveRecord::Migration[7.0]
  def up
    add_column :media_objects, :migration_error, :text

    MigrateMediaObjectsWorker.perform_async
  end

  def down
    remove_column :media_objects, :migration_error
  end
end
