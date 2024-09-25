CREATE OR REPLACE FUNCTION part_tools.get_name_date(_date integer, _date_format text = 'yyyymm'::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT coalesce(to_char(timezone('UTC', '19700101'::timestamp + '1 sec'::interval * _date), _date_format), 'null'::text);
$$;

ALTER FUNCTION part_tools.get_name_date(_date integer, _date_format text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_name_date(_date integer, _date_format text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_name_date(_date integer, _date_format text) IS '
- Перегрузка функции part_tools.get_name_date(timestamptz, text) по первому параметру
- Позволяет запускать создание тригеров для партиций с условием на integer колонку (количество секунд от 19700101 
или количество дней от 19700101 
- Формат запуска создания тригера прежний : 
  select part_tools.create_ddl_trigger_function("схема.таблица", "partitions", "колонка integer", "yyyymm");
  select part_tools.create_ddl_trigger("схема.таблица", "partitions");
  select part_tools.create_trigger("схема.таблица", "partitions");
';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION part_tools.get_name_date(_date timestamp with time zone, _date_format text = 'yyyymm'::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT coalesce(to_char(timezone('UTC', _date), _date_format), 'null'::text);
$$;

ALTER FUNCTION part_tools.get_name_date(_date timestamp with time zone, _date_format text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_name_date(_date timestamp with time zone, _date_format text) FROM PUBLIC;
