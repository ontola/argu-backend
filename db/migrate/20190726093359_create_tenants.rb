class CreateTenants < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared_extensions;'
    ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared_extensions to public;'

    %w[btree_gist hstore ltree uuid-ossp].each do |extension|
      ActiveRecord::Base.connection.execute(
        "UPDATE pg_extension SET extrelocatable = TRUE WHERE extname = '#{extension}';"
      )
      ActiveRecord::Base.connection.execute(
        "ALTER EXTENSION \"#{extension}\" SET SCHEMA shared_extensions;"
      )
    end

    create_table :tenants do |t|
      t.string :iri_prefix, null: false
      t.string :database_schema, null: false, default: 'argu'
      t.uuid :root_id, null: false
    end

    add_index :tenants, :iri_prefix, unique: true

    Apartment::Tenant.create('argu')

    excluded_tables = %w[ar_internal_metadata schema_migrations follows]
    public_tables = Apartment.excluded_models.map { |klass| klass.constantize.table_name.split('.').last }
    prio_tables = %w[users profiles edges groups permitted_actions places]

    migrate_tables(prio_tables)
    migrate_tables(ApplicationRecord.connection.tables.sort - public_tables - excluded_tables - prio_tables)

    follow_columns =
      %w[followable_type follower_id follower_type blocked created_at updated_at send_email follow_type followable_id]

    ApplicationRecord
      .connection
      .execute(
        "INSERT INTO argu.follows (id, #{follow_columns.join(', ')}) SELECT id::uuid, "\
        "#{follow_columns.join(', ')} FROM public.follows;"
      )

    Apartment::Tenant.switch('argu') do
      Page.find_each do |p|
        p.iri_prefix = p.property_instance(NS.argu[:iriPrefix]).string
        p.send(:create_or_update_tenant)
      end
    end
  end

  def migrate_tables(tables)
    tables.each do |table|
      ApplicationRecord.connection.execute("INSERT INTO argu.#{table} SELECT * FROM public.#{table};")
      Apartment::Tenant.switch('argu') do
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      end
    end
  end
end
