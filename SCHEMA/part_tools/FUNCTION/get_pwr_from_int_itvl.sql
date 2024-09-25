CREATE OR REPLACE FUNCTION part_tools.get_pwr_from_int_itvl(_interval text = '1M'::text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _pwr bigint;
  _sfx text;
  _mlp int;
begin
_sfx = regexp_replace(_interval,'^[0-9]*', '');
_mlp = replace(_interval, _sfx, '')::int;
case
    when _sfx = 'K' then _pwr = _mlp * 1000;
    when _sfx = 'M' then _pwr = _mlp * 1000000;
    when _sfx = 'B' then _pwr = _mlp * 1000000000;
    else _pwr = _mlp;
    end case;
return _pwr;
end;
$$;

ALTER FUNCTION part_tools.get_pwr_from_int_itvl(_interval text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_pwr_from_int_itvl(_interval text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_pwr_from_int_itvl(_interval text) IS 'Преобразуем сокращения K, M, B(en) в степени';
