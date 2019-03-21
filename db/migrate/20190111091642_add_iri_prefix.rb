class AddIRIPrefix < ActiveRecord::Migration[5.2]
  def change
    Page.connection.update(
      'INSERT INTO properties (created_at, updated_at, edge_id, predicate, string) ('\
        "SELECT CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, edges.uuid, 'https://argu.co/ns/core#iriPrefix', 'app.argu.co/' || shortnames.shortname FROM edges CROSS JOIN shortnames "\
        "WHERE edges.owner_type = 'Page' AND shortnames.owner_type = 'Edge' AND edges.uuid = shortnames.owner_id AND shortnames.primary = true"\
      ')'
    )

    # Drop unused tables
    drop_table :sources
    drop_table :rules
  end
end
