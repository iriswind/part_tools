CREATE OR REPLACE FUNCTION part_tools.create_range_partitions(_parent_table_name text, _part_schema text, _date_start timestamp with time zone = now(), _interval text = 'month'::text, _count integer = 1, _format text = 'yyyymm'::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _query text;
  _i integer;
  _sfxc text;
  _start_range timestamp with time zone;
  _part_name text;
  _parent_table text;
  _priv text;
  _cons text;
  _sqlstate text;
  _message_text text;
  _context text;
begin
_start_range = part_tools.get_range_start_from_itvl(_date_start, _interval);
_query = '';
if _parent_table_name not ilike('%.%')
    then
    _parent_table = 'public.' || _parent_table_name;
    else
    _parent_table = _parent_table_name;
    end if;
for _i in 1.._count
    loop
    _sfxc = part_tools.get_name_date(_start_range, _format);
    _part_name = _part_schema || '.' || regexp_replace(_parent_table, '^[a-zA-Z_]*.', '') || '_' || _sfxc;
    _query = part_tools.generate_query_create_range_partition(_parent_table,
                                                        _part_schema,
                                                        _start_range,
                                                        _start_range + ('1 ' || _interval)::interval,
                                                        _sfxc);
    _priv = part_tools.get_acl_for_parent_table(_parent_table, _part_name);
    execute _query;
    execute _priv;
    _start_range = _start_range + ('1 ' || _interval)::interval;
    end loop;
raise notice 'Partition % created',_part_name;
      exception
        when others then
          get stacked diagnostics
          _sqlstate = RETURNED_SQLSTATE,
          _message_text = MESSAGE_TEXT,
          _context = PG_EXCEPTION_CONTEXT;
          raise exception 'Cannnot create partition %, %, %, %', _part_name, _sqlstate,_message_text, _context;
end;
$$;

ALTER FUNCTION part_tools.create_range_partitions(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _interval text, _count integer, _format text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.create_range_partitions(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _interval text, _count integer, _format text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.create_range_partitions(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _interval text, _count integer, _format text) IS 'Создаем секции для таблицы на заданный период, ограничения копируем из default-секции';
