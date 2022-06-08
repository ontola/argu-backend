class AddImportantToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :important, :boolean, null: false, default: false

    classes = Edge.descendants
                  .select { |k| k.include?(Edgeable::Content) }
                  .map { |k| k.name.underscore }
    Activity.where("key ~ '#{classes.join('|')}.update|publish'").update_all(important: true)
  end
end
