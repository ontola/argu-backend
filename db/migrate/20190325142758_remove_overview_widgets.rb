class RemoveOverviewWidgets < ActiveRecord::Migration[5.2]
  def up
    Widget.overview.destroy_all
  end
end
