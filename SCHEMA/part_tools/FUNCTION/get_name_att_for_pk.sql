CREATE OR REPLACE FUNCTION part_tools.get_name_att_for_pk(_table_name text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
select a.attname from
    pg_class c join pg_namespace n on c.relnamespace = n.oid
    join pg_attribute a on a.attrelid = c.oid
    join pg_depend d on d.refobjsubid = a.attnum and d.refobjid = c.oid
    join pg_class seq on d.objid = seq.oid and seq.relkind = 'S'
    where n.nspname || '.' || c.relname = _table_name;
$$;

ALTER FUNCTION part_tools.get_name_att_for_pk(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_name_att_for_pk(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_name_att_for_pk(_table_name text) IS 'Для первичного ключа парт. таблицы используем поле с привязанным к нему sequence';
