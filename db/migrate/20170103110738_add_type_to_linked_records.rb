class AddTypeToLinkedRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :linked_records, :record_type, :string
  end
end
