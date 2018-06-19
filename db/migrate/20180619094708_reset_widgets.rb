class ResetWidgets < ActiveRecord::Migration[5.1]
  def change
    Widget.destroy_all
    Forum.find_each do |forum|
      forum.send(:create_default_widgets)
    end
  end
end
