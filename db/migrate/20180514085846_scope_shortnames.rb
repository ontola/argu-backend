class ScopeShortnames < ActiveRecord::Migration[5.1]
  def up
    remove_column :shortnames, :forum_id
    add_column :shortnames, :root_id, :uuid
    add_column :shortnames, :primary, :boolean, default: true, null: false

    remove_index :shortnames, [:owner_id, :owner_type]
    remove_index :shortnames, name: 'index_shortnames_on_shortname'
    add_index :shortnames, [:owner_id, :owner_type], where: '("primary" is true)', unique: true
    execute <<-SQL
      CREATE UNIQUE INDEX index_shortnames_on_scoped_shortname on
      shortnames (lower(shortname), root_id);
    SQL
    execute <<-SQL
      CREATE UNIQUE INDEX index_shortnames_on_unscoped_shortname on
      shortnames (lower(shortname)) WHERE root_id IS NULL;
    SQL

    Shortname.reset_column_information

    Edge.includes(:shortname).where(owner_type: 'Forum').find_each do |edge|
      s = edge.shortname.shortname
      if s.length == 2
        s = "#{s}_"
        puts "#{s} is too short"
      end
      Shortname.create!(shortname: s, owner: edge, root: edge.root, primary: true)
    end

    Shortname
      .joins('INNER JOIN edges ON edges.uuid = shortnames.owner_id AND shortnames.owner_type = \'Edge\' AND edges.owner_type NOT IN (\'Page\', \'Forum\')')
      .update_all(primary: false)
  end
end
