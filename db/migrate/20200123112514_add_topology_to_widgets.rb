class AddTopologyToWidgets < ActiveRecord::Migration[5.2]
  def change
    add_column :widgets, :view, :integer, default: 0, null: false
    Widget.new_motion.update_all(view: 2)
    Widget.new_question.update_all(view: 2)
    Widget.new_topic.update_all(view: 2)
  end
end
