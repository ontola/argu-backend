class ConvertFollowIdToUuid < ActiveRecord::Migration[5.1]
  def change
    add_column :follows, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    change_table :follows do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute 'ALTER TABLE follows ADD PRIMARY KEY (id);'
  end
end
