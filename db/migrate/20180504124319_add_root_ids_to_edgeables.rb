class AddRootIdsToEdgeables < ActiveRecord::Migration[5.1]
  def change
    %w[questions motions arguments votes blog_posts forums vote_events decisions comments linked_records].each do |table|
      klass = table.classify.constantize
      add_column table, :root_id, :uuid
      klass.reset_column_information
      Edge.roots.each do |root|
        klass.joins(:edge).where('edges.path <@ ?', root.id.to_s).update_all(root_id: root.uuid)
      end
      change_column_null table, :root_id, false
    end
  end
end
