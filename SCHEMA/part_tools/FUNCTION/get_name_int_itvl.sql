CREATE OR REPLACE FUNCTION part_tools.get_name_int_itvl(_start_val bigint = 1, _interval text = '1M'::text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _pwr bigint;
  _val text;
  _sfx text;
begin
_pwr =  part_tools.get_pwr_from_int_itvl(_interval);
_sfx = regexp_replace(_interval, '^[0-9]*', '');
_val = (_start_val / _pwr)::text || _sfx;
return _val;
end;
$$;

ALTER FUNCTION part_tools.get_name_int_itvl(_start_val bigint, _interval text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_name_int_itvl(_start_val bigint, _interval text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_name_int_itvl(_start_val bigint, _interval text) IS 'Для таблицы генерируем имя суффикса из интервала';
