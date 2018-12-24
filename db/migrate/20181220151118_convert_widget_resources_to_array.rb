class ConvertWidgetResourcesToArray < ActiveRecord::Migration[5.2]
  def change
    change_column :widgets, :resource_iri, :text, array: true, using: "(ARRAY[string_to_array(resource_iri, ',')])"
    remove_column :widgets, :body
    remove_column :widgets, :label_translation
    remove_column :widgets, :label

    Widget.discussions.destroy_all
    Forum.find_each { |f| f.send(:create_default_widgets) }
  end
end
