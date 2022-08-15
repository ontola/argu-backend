class DropApartment < ActiveRecord::Migration[7.0]
  def change
    raise("Found #{User.count} existing users") if User.where('id > 0').any?

    # Clean up system users
    MediaObject.destroy_all
    User.destroy_all

    Tenant.where(database_schema: 'rivm').delete_all

    remove_column :tenants, :database_schema

    # Should be nullable already
    change_column_null(:grant_resets, :created_at, true)
    change_column_null(:grant_resets, :updated_at, true)

    excluded_tables = %w[ar_internal_metadata schema_migrations follows settings]
    public_tables = %w[tenants oauth_applications]
    prio_tables = %w[users profiles edges groups permitted_actions places active_storage_blobs]

    migrate_tables(prio_tables)
    migrate_tables(ApplicationRecord.connection.tables.sort - public_tables - excluded_tables - prio_tables)

    follow_columns =
      %w[followable_type follower_id follower_type blocked created_at updated_at send_email follow_type followable_id]

    ApplicationRecord
      .connection
      .execute(
        "INSERT INTO public.follows (id, #{follow_columns.join(', ')}) SELECT id::uuid, "\
        "#{follow_columns.join(', ')} FROM argu.follows;"
      )
  end

  private

  def migrate_tables(tables)
    tables.each do |table|
      ApplicationRecord.connection.execute("INSERT INTO public.#{table} SELECT * FROM argu.#{table};")

      ActiveRecord::Base.connection.reset_pk_sequence!(table)
    end
  end
end
