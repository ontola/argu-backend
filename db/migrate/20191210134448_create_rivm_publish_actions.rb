class CreateRIVMPublishActions < ActiveRecord::Migration[5.2]
  def change
    columns = %w[trackable_id trackable_type owner_id owner_type parameters recipient_id recipient_type
                 created_at updated_at audit_data trackable_edge_id recipient_edge_id root_id]
    edge_columns = %w[created_at creator_id publisher_id uuid]
    publication_columns = %w[published_at creator_id publisher_id publishable_id channel]

    %i[intervention measure].each do |klass|
      Activity.connection.execute(
        "INSERT INTO activities(#{columns.join(', ')}, key) SELECT #{columns.join(', ')}, '#{klass}.publish' "\
        "FROM activities WHERE key='#{klass}.create'"
      )

      Publication.connection.execute(
        "INSERT INTO publications(#{publication_columns.join(', ')}) SELECT #{edge_columns.join(', ')}, 'argu' "\
          "FROM edges WHERE owner_type='#{klass.to_s.classify}'"
      )
    end
  end
end
