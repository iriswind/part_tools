CREATE OR REPLACE FUNCTION part_tools.get_range_tables_for_del(_parent_table text, _date timestamp with time zone) RETURNS TABLE(tbl text)
    LANGUAGE sql SECURITY DEFINER
    AS $_$
select chld from
  (select n.nspname || '.' || c.relname as parnt, ni.nspname || '.' || ci.relname as chld, a.attname,
  regexp_split_to_array(regexp_replace(pg_get_expr(ci.relpartbound, ci.oid, true), '(^[a-zA-Z\s\(\'']+)|(\''\)\s)|(\s\(\'')|(\''\)$)','','g'), 'TO') as bounds
    from
    pg_class c join pg_namespace n on c.relnamespace = n.oid
    join pg_partitioned_table p on p.partrelid = c.oid
    join pg_attribute a on a.attrelid = c.oid and a.attnum = any(p.partattrs)
    join pg_inherits i on c.oid = i.inhparent 
    join pg_class ci on i.inhrelid = ci.oid
    join pg_namespace ni on ci.relnamespace = ni.oid
    where c.relkind = 'p' and p.partstrat = 'r' and
    n.nspname || '.' || c.relname = _parent_table
    )p
    where (_date > bounds[2]::timestamp with time zone) and bounds[2] is not null;
$_$;

ALTER FUNCTION part_tools.get_range_tables_for_del(_parent_table text, _date timestamp with time zone) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_range_tables_for_del(_parent_table text, _date timestamp with time zone) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_range_tables_for_del(_parent_table text, _date timestamp with time zone) IS 'Список секций родительской таблицы, у которых range по колонке секционирования ранее чем _date';
