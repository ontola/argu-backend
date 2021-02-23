# frozen_string_literal: true

module Public
  module SPI
    class TestsController < SPI::SPIController
      CLEAN_TABLES = <<END_HEREDOC
DO
$func$
BEGIN
  EXECUTE
  (SELECT 'TRUNCATE TABLE '
    || string_agg(quote_ident(schemaname) || '.' || quote_ident(tablename), ', ')
    || ' CASCADE'
   FROM pg_tables
   WHERE schemaname IN ('public', 'argu')
  );
END
$func$;
END_HEREDOC

      def suite_start
        dump_database
      end

      def suite_stop; end

      def single_start
        clean_database
        restore_database
      end

      def single_stop; end

      private

      def authorize_action
        skip_authorization

        raise(NotAuthorizedError) unless ENV['INTERGRATION_TESTS'] === 'true'
      end

      def clean_database
        ApplicationRecord.connection.execute(CLEAN_TABLES)
      end

      def dump_database
        cmd = with_config do |app, host, db, user, password|
          "PGPASSWORD=#{password} pg_dump --host #{host} --username #{user} --verbose -Fc --data-only #{db} > #{Rails.root}/db/#{app}.dump"
        end

        return if system(cmd)

        Bugsnag.notify("dump_database failed with status code #{$?.exitstatus}")
      end

      def restore_database
        cmd = with_config do |app, host, db, user, password|
          "PGPASSWORD=#{password} pg_restore --verbose --host #{host} --username #{user} --clean -Fc --dbname #{db} #{Rails.root}/db/#{app}.dump"
        end

        return if system(cmd)

        Bugsnag.notify("restore_database failed with status code #{$?.exitstatus}")
      end

      def with_config
        yield Rails.application.class.parent_name.underscore,
          ActiveRecord::Base.connection_config[:host],
          ActiveRecord::Base.connection_config[:database],
          ActiveRecord::Base.connection_config[:username],
          ActiveRecord::Base.connection_config[:password]
      end
    end
  end
end
