CREATE OR REPLACE FUNCTION part_tools.create_range_table(_orig_table_name text, _column text = 'c_date'::text, _part_schema text = 'partitions'::text, _pk_uniq boolean = false) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
_table_name text;
_query text;
_sqlstate text;
_message_text text;
_context text;
begin
if _orig_table_name not ilike('%.%')
    then
    _table_name = 'public.' || _orig_table_name;
    else
    _table_name = _orig_table_name;
    end if;
--Создаем определение полей новой таблицы на основе исходной таблицы
_query = part_tools.generate_part_table_def(_table_name, _column);
execute _query;
--Генерируем для новой таблицы определение всех возможных констрейнтов, в зависимости от параметра _pk_uniq - по умолчанию кроме первичного ключа на основе исходной таблицы
_query = part_tools.generate_part_table_fk_chk_def(_table_name, _pk_uniq);
execute _query;
--Генерируем описание индексов для новой таблицы на основании исходной таблицы
_query = part_tools.generate_part_table_idx_def(_table_name, _pk_uniq);
execute _query;
--Генерируем описание триггеров для новой таблицы на основании исходной таблицы
_query = part_tools.generate_part_table_trg_def(_table_name);
execute _query;
--Генерируем описание прав доступа для новой таблицы на основании исходной таблицы
_query = part_tools.generate_acl_for_part_table(_table_name, _table_name || '_parted');
execute _query;
--Генерируем описание комментариев для новой таблицы на основании исходной таблицы
_query = part_tools.generate_part_table_comm_def(_table_name);
execute _query;
--Создаем default partition, к ней прикручиваем primary key, уникальные индексы, как в оригинальной таблице
--Если _pk_uniq задан на перенос с оригинальной таблицы primary key, то это тоже учитываем
_query = part_tools.generate_query_default_range_partition(_table_name || '_parted', _part_schema, _table_name, not(_pk_uniq));
execute _query;
--Генерируем описание прав доступа для новой таблицы на основании исходной таблицы
_query = part_tools.generate_acl_for_part_table(_table_name, _part_schema || '.' || regexp_replace(_table_name || '_parted_default', '^[a-zA-Z_]*.', ''));
execute _query;
raise notice 'Range table % created', _table_name || '_parted';
      exception
        when others then
          get stacked diagnostics
          _sqlstate = RETURNED_SQLSTATE,
          _message_text = MESSAGE_TEXT,
          _context = PG_EXCEPTION_CONTEXT;
          raise exception 'Cannnot create range table %, %, %, %', _table_name || '_parted', _sqlstate,_message_text, _context;
end;
$$;

ALTER FUNCTION part_tools.create_range_table(_orig_table_name text, _column text, _part_schema text, _pk_uniq boolean) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.create_range_table(_orig_table_name text, _column text, _part_schema text, _pk_uniq boolean) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.create_range_table(_orig_table_name text, _column text, _part_schema text, _pk_uniq boolean) IS 'Генерируем полное определение новой головной таблицы на основе старой, для секционирования нужно указывать поле секционирования';
