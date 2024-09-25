CREATE OR REPLACE FUNCTION part_tools.part_table_has_pk_uniq(_table_name text) RETURNS integer
    LANGUAGE sql
    AS $$
select count(*) cn from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
        where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u');
$$;

ALTER FUNCTION part_tools.part_table_has_pk_uniq(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.part_table_has_pk_uniq(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.part_table_has_pk_uniq(_table_name text) IS 'Определяем, есть ли у таблицы первичный ключ или уникальный констрейнт';
