CREATE OR REPLACE FUNCTION part_tools.get_triggers_for_part_table(_parent_name text, _part_name text) RETURNS TABLE(query_trigger text)
    LANGUAGE sql IMMUTABLE
    AS $$
select 'CREATE TRIGGER ' || trigger_name || ' ' || action_timing || ' ' || string_agg(event_manipulation, ' OR ') ||
      ' ON ' || _part_name || ' FOR EACH ' || action_orientation || ' ' || 
      coalesce('WHEN (' || action_condition || ')', '') || ' ' || action_statement || ';'
      from information_schema.triggers
      where event_object_schema || '.' || event_object_table = _parent_name
      and trigger_name <> 'tpi_' || regexp_replace(_parent_name,'^[a-zA-Z_]*.','')
      group by trigger_name, action_timing, action_orientation, action_condition, action_statement;
$$;

ALTER FUNCTION part_tools.get_triggers_for_part_table(_parent_name text, _part_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_triggers_for_part_table(_parent_name text, _part_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_triggers_for_part_table(_parent_name text, _part_name text) IS 'Генерируем запрос на создание триггера к парт. таблице, исключая триггеры вида tpi_*';
