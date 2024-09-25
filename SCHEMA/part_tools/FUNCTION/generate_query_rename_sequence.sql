CREATE OR REPLACE FUNCTION part_tools.generate_query_rename_sequence(_table_name text, _suff text, _old_suff text = ''::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _seq text;
  _tbl text;
begin
_seq = '';
_tbl = regexp_replace(_table_name, '^[a-zA-Z_]*.', '');
for _t in select s.nm, s.seq from 
    (select n.nspname::text || '.' || c.relname::text as nm,c.relname as seq,c.oid from pg_sequence s join pg_class c on s.seqrelid = c.oid join pg_namespace n on c.relnamespace = n.oid) s
    join pg_depend d on d.objid = s.oid join pg_class c on d.refobjid = c.oid join pg_namespace n on c.relnamespace = n.oid
    where n.nspname::text || '.' || c.relname = _table_name
    loop
    if _old_suff = ''
        then
        _seq = _seq || 'ALTER SEQUENCE ' || _t.nm || ' RENAME TO ' || replace(_t.seq, _tbl, _tbl || _suff) || ';';
        else
        _seq = _seq || 'ALTER SEQUENCE ' || _t.nm || ' RENAME TO ' || replace(_t.seq, _tbl,replace(_tbl, _old_suff, _suff)) || ';';
        end if;
    end loop;
return seq;
end;
$$;

ALTER FUNCTION part_tools.generate_query_rename_sequence(_table_name text, _suff text, _old_suff text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_query_rename_sequence(_table_name text, _suff text, _old_suff text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_query_rename_sequence(_table_name text, _suff text, _old_suff text) IS 'Генерируем переименование сиквенса с новым указанным суффиксом либо взамен вместо старого суффикса';
