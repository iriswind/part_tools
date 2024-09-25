CREATE OR REPLACE FUNCTION part_tools.generate_part_table_fk_chk_def(_table_name text, _pk_uniq boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _fk text;
  _tbl text;
begin
_fk = '';
_tbl = regexp_replace(_table_name, '^[a-zA-Z_]*.', '');
for _t in select con.conname, pg_get_constraintdef(con.oid) def
    from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
    where n.nspname || '.' || c.relname = _table_name and con.contype in ('f', 'c')
    loop
    _fk = _fk || 'ALTER TABLE ' || _table_name || '_parted' || ' ADD CONSTRAINT ' || replace(_t.conname, _tbl, _tbl || '_parted') || ' ' || _t.def || ';';
    end loop;
if _pk_uniq = true
  then
  for _t in select con.conname, pg_get_constraintdef(con.oid) def
      from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
      where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u')
      loop
      _fk = _fk || 'ALTER TABLE ' || _table_name || '_parted' || ' ADD CONSTRAINT ' || replace(_t.conname, _tbl, _tbl || '_parted') || ' ' || _t.def || ';';
      end loop;
  end if;
return _fk;
end;
$$;

ALTER FUNCTION part_tools.generate_part_table_fk_chk_def(_table_name text, _pk_uniq boolean) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_part_table_fk_chk_def(_table_name text, _pk_uniq boolean) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_part_table_fk_chk_def(_table_name text, _pk_uniq boolean) IS 'Генерируем определение внешних ключей для создаваемой партиционированной таблицы с суффиксом _parted';
