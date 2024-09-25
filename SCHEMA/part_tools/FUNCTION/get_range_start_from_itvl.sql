CREATE OR REPLACE FUNCTION part_tools.get_range_start_from_itvl(_date timestamp with time zone = now(), _itvl text = 'month'::text) RETURNS timestamp with time zone
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _dt timestamp with time zone;
  _dtw timestamp with time zone;
  _yr text;
  _mnth text;
  _wkd text;
  _dy text;
begin
if _itvl = 'week'
    then
    if extract(dow from _date) = 0
        then
        _dtw = _date-'6 day'::interval;
        else
        _dtw = _date-((extract(dow from _date)-1)::text || ' day')::interval;
        end if;
    else
    _dtw = _date;
    end if;
_yr = extract(year from _dtw)::text;
if extract(month from _dtw)<10 
    then 
    _mnth = '0' || extract(month from _dtw)::text;
    else 
    _mnth = extract(month from _dtw)::text;
    end if;
if extract(day from _dtw)<10 
    then 
    _dy = '0' || extract(day from _dtw)::text;
    else 
    _dy = extract(day from _dtw)::text;
    end if;
case
   when _itvl = 'year' then
     _dt = (_yr || '-01-01 00:00:00.000000+00')::timestamp with time zone;
   when _itvl = 'month' then
     _dt = (_yr || '-' || _mnth || '-01 00:00:00.000000+00')::timestamp with time zone;
   when _itvl = 'day' or _itvl = 'week' then
     _dt = (_yr || '-' || _mnth || '-' || _dy || ' 00:00:00.000000+00')::timestamp with time zone;
   else
   _dt = null;   
   end case;
return _dt;
end;
$$;

ALTER FUNCTION part_tools.get_range_start_from_itvl(_date timestamp with time zone, _itvl text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_range_start_from_itvl(_date timestamp with time zone, _itvl text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_range_start_from_itvl(_date timestamp with time zone, _itvl text) IS 'Получаем дату начала интервала';
