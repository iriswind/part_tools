CREATE OR REPLACE FUNCTION part_tools.rename_table_and_objects(_orig_table_name text, _suff text, _old_suff text = ''::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _table_name text;
  _query text;
  _sqlstate text;
  _message_text text;
  _context text;
  _t record;
begin
if _orig_table_name not ilike('%.%')
    then
    _table_name = 'public.' || _orig_table_name;
    else
    _table_name = _orig_table_name;
    end if;
for _t in select chn.nspname || '.' || ch.relname as relname from pg_inherits h join pg_class p on p.oid=h.inhparent join pg_namespace n on n.oid = p.relnamespace
     left join pg_class ch on h.inhrelid=ch.oid join pg_namespace chn on ch.relnamespace = chn.oid
     where  n.nspname || '.' || p.relname = _table_name
     loop
     _query = part_tools.generate_query_rename_tbl_con_idx(_t.relname, _suff, _old_suff, false);
     execute _query;
     end loop;
_query = part_tools.generate_query_rename_tbl_con_idx(_table_name, _suff, _old_suff, true);
execute _query;
raise notice 'Table % renamed', _table_name;
      exception
        when others then
          get stacked diagnostics
          _sqlstate = RETURNED_SQLSTATE,
          _message_text = MESSAGE_TEXT,
          _context = PG_EXCEPTION_CONTEXT;
          raise exception 'Cannnot rename table %, %, %, %', _table_name, _sqlstate, _message_text, _context;
end;
$$;

ALTER FUNCTION part_tools.rename_table_and_objects(_orig_table_name text, _suff text, _old_suff text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.rename_table_and_objects(_orig_table_name text, _suff text, _old_suff text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.rename_table_and_objects(_orig_table_name text, _suff text, _old_suff text) IS 'Выполняем переименование таблицы и всех ее дочерних таблиц, констрейнтов, индексов с новым указанным суффиксом либо взамен вместо старого суффикса';
