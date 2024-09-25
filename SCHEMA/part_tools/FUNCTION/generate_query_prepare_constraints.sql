CREATE OR REPLACE FUNCTION part_tools.generate_query_prepare_constraints(_table_name text) RETURNS TABLE(drop_fk text, create_fk text)
    LANGUAGE sql IMMUTABLE
    AS $$
select 'alter table ' || nf.nspname || '.' || cf.relname || ' drop constraint ' || con.conname || ';' as drop_fk,
    'alter table ' || nf.nspname || '.' || cf.relname || ' add constraint ' || con.conname || ' ' || pg_get_constraintdef(con.oid) || ';' as create_fk 
    from pg_class c join pg_namespace n on c.relnamespace = n.oid
    join pg_constraint con on c.oid = con.confrelid
    join pg_class cf on cf.oid = con.conrelid join pg_namespace nf on cf.relnamespace = nf.oid
    where n.nspname || '.' || c.relname = _table_name;
$$;

ALTER FUNCTION part_tools.generate_query_prepare_constraints(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_prepare_constraints(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_prepare_constraints(_table_name text) IS 'Получаем запросы на удаление и создание внешних ключей, ссылающихся на указанную таблицу';
