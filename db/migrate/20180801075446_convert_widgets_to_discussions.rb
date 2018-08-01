class ConvertWidgetsToDiscussions < ActiveRecord::Migration[5.2]
  def up
    Widget.destroy_all
    Forum.find_each do |forum|
      forum.send(:create_default_widgets)
    end
  end
end
