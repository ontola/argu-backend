class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets do |t|
      t.integer :widget_type, null: false
      t.string :owner_type, null: false
      t.integer :owner_id, null: false
      t.string :resource_iri, null: false
      t.string :label
      t.boolean :label_translation, default: false, null: false
      t.text :body
      t.integer :size, null: false, default: 1
      t.integer :position, null: false
      t.index [:owner_type, :owner_id]
    end

    Forum.find_each do |forum|
      forum.send(:create_default_widgets)
    end
  end
end
