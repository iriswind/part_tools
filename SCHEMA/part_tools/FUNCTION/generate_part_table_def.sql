CREATE OR REPLACE FUNCTION part_tools.generate_part_table_def(_table_name text, _column text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT 'CREATE TABLE ' || _table_name || '_parted' || '(' ||
    part_tools.get_table_columns_def(_table_name) ||
    ')' || E'\n' || ' PARTITION BY RANGE (' || _column || ');' ||
    part_tools.generate_acl_for_part_table(_table_name, _table_name || '_parted');
$$;

ALTER FUNCTION part_tools.generate_part_table_def(_table_name text, _column text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_part_table_def(_table_name text, _column text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_part_table_def(_table_name text, _column text) IS 'Генерируем определение партиционированной таблицы';
