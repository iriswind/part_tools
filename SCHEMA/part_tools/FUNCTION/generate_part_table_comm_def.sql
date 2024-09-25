CREATE OR REPLACE FUNCTION part_tools.generate_part_table_comm_def(_table_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _comm text;
begin
_comm = '';
for _t in select
    distinct case
        when objsubid = 0 then 'COMMENT ON TABLE ' || n.nspname || '.' || c.relname || '_parted' || ' IS ''' || dt.description || ''''
        else 'COMMENT ON COLUMN ' || n.nspname || '.' || c.relname || '_parted' ||'.' || a.attname || ' IS ''' || dt.description || ''''
        end def
    from pg_namespace n join pg_class c on c.relnamespace = n.oid
    join pg_attribute a on  a.attrelid = c.oid 
    left join pg_description dt on dt.objoid = c.oid 
    where n.nspname || '.' || c.relname = _table_name and (a.attnum = dt.objsubid or dt.objsubid = 0)
    loop
    _comm = _comm || _t.def || ';';
    end loop;
return _comm;
end;
$$;

ALTER FUNCTION part_tools.generate_part_table_comm_def(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_part_table_comm_def(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_part_table_comm_def(_table_name text) IS 'Генерируем комментарии партиционированной таблицы';
