CREATE OR REPLACE FUNCTION part_tools.get_name_att_for_check(_table_name text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
select a.attname from
  pg_class c join pg_namespace n on c.relnamespace = n.oid
  join pg_partitioned_table p on p.partrelid = c.oid
  join pg_attribute a on a.attrelid = c.oid and a.attnum = any(p.partattrs)
  where c.relkind = 'p' and n.nspname || '.' || c.relname = _table_name;
$$;

ALTER FUNCTION part_tools.get_name_att_for_check(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_name_att_for_check(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_name_att_for_check(_table_name text) IS 'Для CHECK-констрейнта парт. таблицы используем поле, по которому задано партиционирование RANGE';
