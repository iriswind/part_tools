CREATE OR REPLACE FUNCTION part_tools.get_table_columns_def(_table_name text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
select string_agg(o.def, E',\n    ') from 
    (select a.attname || ' ' ||
          case when a.atttypid = any ('{int,int8,int2}'::regtype[]) and
              exists (select * from pg_attrdef ad where ad.adrelid = a.attrelid and ad.adnum = a.attnum and
	      pg_get_expr(ad.adbin, ad.adrelid) = 'nextval(''' || (pg_get_serial_sequence (a.attrelid::regclass::text, a.attname))::regclass || '''::regclass)') then 
	      case a.atttypid 
	        when 'int'::regtype then'serial' 
	        when 'int8'::regtype then 'bigserial'
	        when 'int2'::regtype then 'smallserial'
	        end
	      else format_type(a.atttypid, a.atttypmod)
	      end ||
	  case 
	    when a.attnotnull then ' NOT NULL'
	    else ''
	    end ||
	  case 
	    when a.atthasdef and pg_get_expr(ad.adbin, ad.adrelid) not ilike ('nextval%') then ' DEFAULT ' || pg_get_expr(ad.adbin, ad.adrelid)
	    else ''
	    end as def,
	  a.attnum, a.attidentity, a.attgenerated, a.atthasdef, pg_get_expr(ad.adbin, ad.adrelid)
    from pg_namespace n join pg_class c on c.relnamespace = n.oid
    join pg_attribute a on a.attrelid = c.oid
    join pg_type t on a.atttypid = t.oid
    left join pg_attrdef ad on (a.attrelid = ad.adrelid and a.attnum = ad.adnum)
    where n.nspname || '.' || c.relname = _table_name and a.attnum > 0 and not a.attisdropped order by  a.attnum) o;
$$;

ALTER FUNCTION part_tools.get_table_columns_def(_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_table_columns_def(_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_table_columns_def(_table_name text) IS 'Получаем описание колонок таблицы';
