CREATE OR REPLACE FUNCTION part_tools.get_acl_for_parent_table(_parent_table_name text, _part_table_name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  _priv text;
  _rec record;
BEGIN
_priv='';
for _rec in select r.rolname,acl.privilege_type from
  (select (aclexplode(relacl)).grantee, (aclexplode(relacl)).privilege_type
    from pg_class c join pg_namespace n on c.relnamespace = n.oid where n.nspname || '.' || c.relname=_parent_table_name) acl
  join pg_roles r on acl.grantee = r.oid
    loop
    _priv = _priv || 'GRANT ' || _rec.privilege_type || ' ON TABLE ' || _part_table_name || ' TO ' || _rec.rolname || ';' || E'\n';  
    end loop;
return _priv;
END;
$$;

ALTER FUNCTION part_tools.get_acl_for_parent_table(_parent_table_name text, _part_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.get_acl_for_parent_table(_parent_table_name text, _part_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.get_acl_for_parent_table(_parent_table_name text, _part_table_name text) IS 'Возвращаем шаблон прав для дочерней таблицы';
