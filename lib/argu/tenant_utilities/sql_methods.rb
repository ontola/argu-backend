module Argu
  module TenantUtilities
    module SQLMethods
      def custom_belongs_to(model, t_name, t_id, foreign_id_column, foreign_type_column)
        migration_base_sql(model, t_name) +
            "where #{foreign_id_column} = #{t_id} AND #{foreign_type_column} = 'Forum'; "
      end

      def in_statement(model, t_name, t_id, foreign_column, other_class, pluck_column = :id)
        in_statement!(model, t_name, t_id, foreign_column, other_class.where(forum_id: t_id).pluck(pluck_column))
      end

      def in_statement!(model, t_name, t_id, foreign_column, id_array)
        if id_array.length > 0
          migration_base_sql(model, t_name) +
              "where #{foreign_column} IN (#{id_array.join(', ')}); "
        else
          ''
        end
      end

      def migration_base_sql(model_klass, to_tenant, from_tenant = 'public')
        "insert into #{to_tenant}.#{model_klass.model_name.collection} (#{quoted_column_names(model_klass)}) " +
            "select #{quoted_column_names(model_klass)} " +
            "from #{from_tenant}.#{model_klass.model_name.collection} "
      end

      def quoted_column_names(klass)
        "#{klass.column_names.map { |i| "\"#{i}\""  }.join(', ')} "
      end
    end
  end
end
