# frozen_string_literal: true

module PostgresFix
  def lookup_cast_type_from_column(column)
    type = get_oid_type(column.oid, column.fmod, column.name, column.sql_type || '')
    if column&.name == 'children_counts' && !type.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Hstore)
      Bugsnag.notify(RuntimeError.new("found wrong type for children_counts: #{type}"))
    end

    type
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(PostgresFix)
