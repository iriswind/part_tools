CREATE OR REPLACE FUNCTION part_tools.drop_range_partition(_part_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  _sqlstate text;
  _message_text text;
  _context text;
BEGIN
EXECUTE 'DROP TABLE ' || _part_name;
raise notice 'Partition % deleted', _part_name;
      exception
        when others then
          get stacked diagnostics
          _sqlstate = RETURNED_SQLSTATE,
          _message_text = MESSAGE_TEXT,
          _context = PG_EXCEPTION_CONTEXT;
          raise exception 'Cannnot deleted partition %, %, %, %', _part_name, _sqlstate,_message_text, _context;
END;
$$;

ALTER FUNCTION part_tools.drop_range_partition(_part_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.drop_range_partition(_part_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.drop_range_partition(_part_name text) IS 'Удаляем парт. таблицу';
