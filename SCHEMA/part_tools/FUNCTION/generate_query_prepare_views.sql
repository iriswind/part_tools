CREATE OR REPLACE FUNCTION part_tools.generate_query_prepare_views(_table_name text) RETURNS TABLE(drop_view text, create_view text)
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _tbl text;
  _r record;
  _v record;
begin
--В представлении таблица может быть использована без имени схемы, попробуем это учесть
_tbl = regexp_replace(_table_name, '^[a-zA-Z_]*.', '');
for _r in select * from pg_views where definition ilike ('%' || _table_name || '%') or definition ilike ('%' || _tbl || '%')
  loop
  select into _v * from part_tools.generate_acl_for_part_table(_r.schemaname || '.' || _r.viewname, _r.schemaname || '.' || _r.viewname);
  drop_view = 'drop view ' || _r.schemaname || '.' || _r.viewname || ';';
  create_view = 'create view ' || _r.schemaname || '.' || _r.viewname || ' as ' || _r.definition || _v.generate_acl_for_part_table;
  return next;
  end loop;
return;
end;
$$;

ALTER FUNCTION part_tools.generate_query_prepare_views(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_prepare_views(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_prepare_views(_table_name text) IS 'Получаем запросы на удаление и создание представлений, использующих указанную таблицу';
