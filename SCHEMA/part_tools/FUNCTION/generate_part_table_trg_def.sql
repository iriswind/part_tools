CREATE OR REPLACE FUNCTION part_tools.generate_part_table_trg_def(_table_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  _t record;
  _tg text;
begin
_tg = '';
for _t in select replace(pg_get_triggerdef(trg.oid), _table_name, _table_name || '_parted') def
    from pg_trigger trg join pg_class c on trg.tgrelid = c.oid
    join pg_namespace n on c.relnamespace = n.oid where n.nspname || '.' || c.relname = _table_name
    and trg.tgisinternal = false
    loop
    _tg = _tg || _t.def || ';';
    end loop;
return _tg;
end;
$$;

ALTER FUNCTION part_tools.generate_part_table_trg_def(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_part_table_trg_def(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_part_table_trg_def(_table_name text) IS 'Генерируем определение триггеров для создаваемой партиционированной таблицы с суффиксом _parted';
