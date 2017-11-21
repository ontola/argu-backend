class DropProjects < ActiveRecord::Migration[5.1]
  def change
    Question.where('project_id IS NOT NULL').destroy_all
    Motion.where('project_id IS NOT NULL').destroy_all
    remove_column :motions, :project_id
    remove_column :questions, :project_id

    Activity.where(trackable_type: 'Project').destroy_all
    Activity.where(recipient_type: 'Project').destroy_all
    Phase.destroy_all
    Project.destroy_all

    drop_table :phases
    drop_table :projects
  end
end
