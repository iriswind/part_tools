CREATE OR REPLACE FUNCTION part_tools.generate_query_default_range_partition(_parent_table_name text, _part_schema text, _orig_table text, _pk_uniq boolean) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
declare
  _table_name text;
  _parent_schema text;
  _quer text;
begin
_table_name = regexp_replace(_parent_table_name, '^[a-zA-Z_]*.', '');
_parent_schema = regexp_replace(_parent_table_name, '.[a-zA-Z_]*$', '');
_quer = 'CREATE TABLE IF NOT EXISTS ' || _part_schema || '.' || _table_name || '_default' || ' PARTITION OF ' || _parent_table_name  || ' DEFAULT;';
if _pk_uniq = true
  then
  _quer = _quer || part_tools.generate_uniq_def(_orig_table, _part_schema || '.' || _table_name || '_default');
  end if;
return _quer;
end;
$_$;

ALTER FUNCTION part_tools.generate_query_default_range_partition(_parent_table_name text, _part_schema text, _orig_table text, _pk_uniq boolean) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_default_range_partition(_parent_table_name text, _part_schema text, _orig_table text, _pk_uniq boolean) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_default_range_partition(_parent_table_name text, _part_schema text, _orig_table text, _pk_uniq boolean) IS 'Генерируем определение default-секции, ограничения уникальности и первичного ключа копируем с оригинальной таблицы';
