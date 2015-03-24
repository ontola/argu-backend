class ChangeShortnameIndexToCaseInsensitive < ActiveRecord::Migration
  def change

    remove_index :shortnames, :shortname

    execute <<-SQL
      CREATE UNIQUE INDEX index_shortnames_on_shortname on
      shortnames (lower(shortname));
    SQL

  end
end
