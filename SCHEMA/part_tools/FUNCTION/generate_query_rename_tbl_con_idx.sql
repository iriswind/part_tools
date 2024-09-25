CREATE OR REPLACE FUNCTION part_tools.generate_query_rename_tbl_con_idx(_table_name text, _suff text, _old_suff text = ''::text, _rename_constr boolean = false) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _con text;
  _tbl text;
begin
_con = '';
_tbl = regexp_replace(_table_name, '^[a-zA-Z_]*.', '');
if _rename_constr = true
  then
  for _t in select con.conname
    from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
      where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u', 'f', 'c')
      loop
      if _old_suff = ''
        then
        _con = _con || 'ALTER TABLE ' || _table_name || ' RENAME CONSTRAINT ' || _t.conname || ' TO ' || replace(_t.conname, _tbl, _tbl || _suff) || ';';
        else
        _con = _con || 'ALTER TABLE ' || _table_name || ' RENAME CONSTRAINT ' || _t.conname || ' TO ' || replace(_t.conname, _tbl, replace(_tbl, _old_suff, _suff)) || ';';
        end if;
    end loop;
  end if;
for _t in select ni.nspname || '.' || c.relname as full_idx, c.relname as idx
    from pg_index i join pg_class c on i.indexrelid = c.oid join pg_namespace ni on c.relnamespace = ni.oid
    join pg_class cpar on i.indrelid = cpar.oid join pg_namespace npar on cpar.relnamespace = npar.oid
    where npar.nspname || '.' || cpar.relname = _table_name
    and c.relname not in (select con.conname from pg_constraint con join pg_class c on con.conrelid = c.oid join pg_namespace n on c.relnamespace = n.oid
        where n.nspname || '.' || c.relname = _table_name and con.contype in ('p', 'u'))
  loop
    if _old_suff = ''
      then
      _con = _con || 'ALTER INDEX ' || _t.full_idx || ' RENAME TO ' || replace(_t.idx, _tbl, _tbl || _suff) || ';';
       else
       _con = _con || 'ALTER INDEX ' || _t.full_idx || ' RENAME TO ' || replace(_t.idx, _tbl, replace(_tbl, _old_suff, _suff)) || ';';
       end if;    
   end loop;
if _old_suff = ''
  then
  _con = _con || 'ALTER TABLE ' || _table_name || ' RENAME TO ' || _tbl || _suff || ';';
  else
  _con = _con || 'ALTER TABLE ' || _table_name || ' RENAME TO ' || replace(_tbl, _old_suff, _suff) || ';';
  end if;
return _con;
end;
$$;

ALTER FUNCTION part_tools.generate_query_rename_tbl_con_idx(_table_name text, _suff text, _old_suff text, _rename_constr boolean) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_rename_tbl_con_idx(_table_name text, _suff text, _old_suff text, _rename_constr boolean) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_rename_tbl_con_idx(_table_name text, _suff text, _old_suff text, _rename_constr boolean) IS 'Генерируем переименование констрейнтов, индексов с новым указанным суффиксом либо взамен вместо старого суффикса';
