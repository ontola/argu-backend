--
-- This is the functions.sql file used by Squirm-Rails. Define your Postgres stored
-- procedures in this file and they will be loaded at the end of any calls to the
-- db:schema:load Rake task.
--

CREATE OR REPLACE FUNCTION hello_world() RETURNS TEXT AS $$
  BEGIN
    RETURN 'hello world!';
  END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION increment_counter(table_name text, column_name text, id integer, step integer)
  RETURNS VOID AS $$
    DECLARE
      table_name text := quote_indent(table_name);
      column_name text := quote_indent(column_name);
      conditions text := ' WHERE id = $1';
      updates text := column_name || '=' || column_name || '+' || step;
    BEGIN
      EXECUTE 'UPDATE ' || table_name || ' SET ' || updates || conditions
      USING id;
    END;
  $$ LANGUAGE PLPGSQL;
