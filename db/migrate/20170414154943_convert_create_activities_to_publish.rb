class ConvertCreateActivitiesToPublish < ActiveRecord::Migration[5.0]
  def up
    Activity.where(key: 'motion.create').where('id < ?', 32870).order(:created_at).update_all(key: 'motion.publish')
    Activity.where(key: 'question.create').where('id < ?', 32905).order(:created_at).update_all(key: 'question.publish')
  end
end
