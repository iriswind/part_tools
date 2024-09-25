CREATE OR REPLACE FUNCTION part_tools.generate_part_table_idx_def(_table_name text, _pk_uniq boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _idx text;
begin
_idx = '';
for _t in select replace(pg_get_indexdef(i.indexrelid), cpar.relname, cpar.relname || '_parted') def
    from pg_index i join pg_class c on i.indexrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
    join pg_class cpar on i.indrelid = cpar.oid join pg_namespace npar on cpar.relnamespace = npar.oid
    where npar.nspname || '.' || cpar.relname = _table_name and i.indisprimary = false and i.indisunique = false
    loop
    _idx = _idx || _t.def || ';';
    end loop;
if _pk_uniq = true
  then
  for _t in select replace(pg_get_indexdef(i.indexrelid), cpar.relname, cpar.relname || '_parted') def
    from pg_index i join pg_class c on i.indexrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
    join pg_class cpar on i.indrelid = cpar.oid join pg_namespace npar on cpar.relnamespace = npar.oid
    where npar.nspname || '.' || cpar.relname = _table_name and i.indisprimary = false and i.indisunique = true
    loop
    _idx = _idx || _t.def || ';';
    end loop;
  end if;
return _idx;
end;
$$;

ALTER FUNCTION part_tools.generate_part_table_idx_def(_table_name text, _pk_uniq boolean) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_part_table_idx_def(_table_name text, _pk_uniq boolean) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_part_table_idx_def(_table_name text, _pk_uniq boolean) IS 'Генерируем определение индексов, кроме первичного ключа, для создаваемой партиционированной таблицы с суффиксом _parted';
