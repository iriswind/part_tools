CREATE OR REPLACE FUNCTION part_tools.delete_range_tables(_parent_table_name text, _date_from_now interval = '3 mons'::interval) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _r record;
  _parent_table text;
begin
if _parent_table_name not ilike('%.%')
    then
    _parent_table='public.' || _parent_table_name;
    else
    _parent_table=_parent_table_name;
    end if;
for _r in select tbl from part_tools.get_range_tables_for_del(_parent_table, now() + _date_from_now)
    loop
    perform part_tools.detach_range_partition(_parent_table,_r.tbl);
    perform part_tools.drop_range_partition(_r.tbl);
    end loop;
end;
$$;

ALTER FUNCTION part_tools.delete_range_tables(_parent_table_name text, _date_from_now interval) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.delete_range_tables(_parent_table_name text, _date_from_now interval) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.delete_range_tables(_parent_table_name text, _date_from_now interval) IS 'Удаляем парт. таблицу';
