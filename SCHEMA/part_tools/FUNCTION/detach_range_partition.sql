CREATE OR REPLACE FUNCTION part_tools.detach_range_partition(_parent_name text, _part_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  _sqlstate text;
  _message_text text;
  _context text;
BEGIN
EXECUTE 'ALTER TABLE ' || _parent_name || ' DETACH PARTITION ' || _part_name;
raise notice 'Partition % detached', _part_name;
      exception
        when others then
          get stacked diagnostics
          _sqlstate = RETURNED_SQLSTATE,
          _message_text = MESSAGE_TEXT,
          _context = PG_EXCEPTION_CONTEXT;
          raise exception 'Cannnot detach partition %, %, %, %', _part_name, _sqlstate,_message_text, _context;
END;
$$;

ALTER FUNCTION part_tools.detach_range_partition(_parent_name text, _part_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.detach_range_partition(_parent_name text, _part_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.detach_range_partition(_parent_name text, _part_name text) IS 'Отсоединяем парт. таблицу';
