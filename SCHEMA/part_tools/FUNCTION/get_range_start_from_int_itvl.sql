CREATE OR REPLACE FUNCTION part_tools.get_range_start_from_int_itvl(_start_val bigint = 1, _interval text = '1M'::text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _pwr bigint;
  _val bigint;
begin
_pwr =  part_tools.get_pwr_from_int_itvl(_interval);
_val = _start_val - _start_val%_pwr + 1;
return _val;
end;
$$;

ALTER FUNCTION part_tools.get_range_start_from_int_itvl(_start_val bigint, _interval text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_range_start_from_int_itvl(_start_val bigint, _interval text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_range_start_from_int_itvl(_start_val bigint, _interval text) IS 'Получаем начало интервала';
