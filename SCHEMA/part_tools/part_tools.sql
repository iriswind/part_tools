CREATE SCHEMA part_tools;

ALTER SCHEMA part_tools OWNER TO pg_database_owner;

GRANT ALL ON SCHEMA part_tools TO pg_database_owner;

COMMENT ON SCHEMA part_tools IS 'Инструменты для партицианироания таблиц';
