CREATE OR REPLACE FUNCTION part_tools.generate_uniq_def(_table_name text, _default_part_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _con text;
  _tbl text;
  _tbld text;
  _schema_tbl text;
  _schema_tbld text;
begin
_con = '';
_tbl = regexp_replace(_table_name, '^[a-zA-Z_]*.', '');
_schema_tbl = replace(_table_name, '.' || _tbl, '');
_tbld = regexp_replace(_default_part_name, '^[a-zA-Z_]*.', '');
_schema_tbld = replace(_default_part_name, '.' || _tbld, '');
for _t in select con.conname,pg_get_constraintdef(con.oid) def
    from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
    where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u')
    loop
    _con = _con || 'ALTER TABLE ' || _default_part_name || ' ADD CONSTRAINT ' || replace(_t.conname, _tbl, _tbld) || ' ' || _t.def || ';';
    end loop;
for _t in select replace(replace(pg_get_indexdef(i.indexrelid), cpar.relname, _tbld), _schema_tbl, _schema_tbld) def
    from pg_index i join pg_class c on i.indexrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
    join pg_class cpar on i.indrelid = cpar.oid join pg_namespace npar on cpar.relnamespace = npar.oid
    where npar.nspname || '.' || cpar.relname = _table_name and i.indisunique = true and i.indisprimary = false
    and c.relname not in (select con.conname from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
        where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u'))
    loop
    _con = _con || _t.def || ';';
    end loop;
return _con;
end;
$$;

ALTER FUNCTION part_tools.generate_uniq_def(_table_name text, _default_part_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_uniq_def(_table_name text, _default_part_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_uniq_def(_table_name text, _default_part_name text) IS 'Генерируем определение первичного ключа и уникальных констрейнтов и индексов для default partition';
