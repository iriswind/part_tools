CREATE OR REPLACE FUNCTION part_tools.create_range_partitions_int(_parent_table_name text, _part_schema text, _start_val bigint = 1, _interval text = '1M'::text, _count integer = 1) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _query text;
  _i integer;
  _sfxc text;
  _start_range bigint;
  _part_name text;
  _parent_table text;
  _priv text;
  _cons text;
  _sqlstate text;
  _message_text text;
  _context text;
  _pwr bigint;
  _sfx text;
  _mlp int;
begin
_sfx = regexp_replace(_interval, '^[0-9]*', '');
_pwr  = part_tools.get_pwr_from_int_itvl(_interval);
_start_range = part_tools.get_range_start_from_int_itvl(_start_val, _interval);
_query = '';
if _parent_table_name not ilike('%.%')
    then
    _parent_table = 'public.' || _parent_table_name;
    else
    _parent_table = _parent_table_name;
    end if;
for i in 0.._count - 1
    loop
    _sfxc = part_tools.get_name_int_itvl(_start_range, _interval);
    _part_name = _part_schema || '.' ||regexp_replace(_parent_table, '^[a-zA-Z_]*.', '') || '_' || _sfxc;
    _query = part_tools.generate_query_create_range_partition_int(_parent_table,
                                                        _part_schema,
                                                        _start_range,
                                                        _start_range + _pwr,
                                                        _sfxc);
    _priv = part_tools.get_acl_for_parent_table(_parent_table, _part_name);
    execute _query;
    execute _priv;
    _start_range = _start_range + _pwr;
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

ALTER FUNCTION part_tools.create_range_partitions_int(_parent_table_name text, _part_schema text, _start_val bigint, _interval text, _count integer) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.create_range_partitions_int(_parent_table_name text, _part_schema text, _start_val bigint, _interval text, _count integer) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.create_range_partitions_int(_parent_table_name text, _part_schema text, _start_val bigint, _interval text, _count integer) IS 'Создаем секции для таблицы на заданный период, ограничения копируем из default-секции';
