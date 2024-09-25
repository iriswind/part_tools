CREATE OR REPLACE FUNCTION part_tools.generate_query_create_range_partition(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _date_end timestamp with time zone, _suffix text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
declare
  _table_name text;
  _parent_schema text;
  _quer text;
begin
_table_name = regexp_replace(_parent_table_name, '^[a-zA-Z_]*.', '');
_parent_schema = regexp_replace(_parent_table_name, '.[a-zA-Z_]*$', '');
_quer = 'CREATE TABLE IF NOT EXISTS ' || _part_schema || '.' || _table_name || '_' || _suffix || ' PARTITION OF ' || _parent_table_name  || 
     ' FOR VALUES FROM (''' || _date_start::text || ''') TO (''' || _date_end::text || ''');';
if part_tools.part_table_has_pk_uniq(_parent_table_name) = 0
  then
  _quer = _quer || part_tools.generate_uniq_def(_part_schema || '.' || _table_name  || '_default', _part_schema || '.' || _table_name || '_' || _suffix);
  end if;
return _quer;
end;
$_$;

ALTER FUNCTION part_tools.generate_query_create_range_partition(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _date_end timestamp with time zone, _suffix text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_create_range_partition(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _date_end timestamp with time zone, _suffix text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_create_range_partition(_parent_table_name text, _part_schema text, _date_start timestamp with time zone, _date_end timestamp with time zone, _suffix text) IS 'Генерируем определение конкретной секции для таблицы, ограничения копируем из default-секции';
