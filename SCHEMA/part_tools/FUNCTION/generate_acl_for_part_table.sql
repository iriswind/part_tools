CREATE OR REPLACE FUNCTION part_tools.generate_acl_for_part_table(_table_name text, _part_table_name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
    AS $$
declare
  _priv text;
  _rec record;
BEGIN
_priv = '';
for _rec in select r.rolname, tacl.privilege_type, ownr from
           (select tbl_acl.ownr, (aclexplode(tbl_acl.relacl)).grantee, (aclexplode(tbl_acl.relacl)).privilege_type from
           (select  ownr.rolname as ownr,
           case when relacl is null then ('{' || ownr.rolname || '=arwdDxt/' || ownr.rolname || '}')::aclitem[] else relacl end as relacl
           from pg_class c join pg_namespace n on c.relnamespace = n.oid
           join pg_roles ownr on c.relowner = ownr.oid
           where n.nspname || '.' || c.relname = _table_name) tbl_acl) tacl
           join pg_roles r on tacl.grantee = r.oid
    loop
    _priv = _priv || 'GRANT ' || _rec.privilege_type || ' ON TABLE ' || _part_table_name || ' TO ' || _rec.rolname || ';' || E'\n';  
    end loop;
    _priv = E'\n' || 'ALTER TABLE ' || _part_table_name || ' OWNER TO ' || _rec.ownr || ';' || E'\n' || _priv;
return _priv;
END;
$$;

ALTER FUNCTION part_tools.generate_acl_for_part_table(_table_name text, _part_table_name text) OWNER TO pg_database_owner;

REVOKE ALL ON FUNCTION part_tools.generate_acl_for_part_table(_table_name text, _part_table_name text) FROM PUBLIC;

COMMENT ON FUNCTION part_tools.generate_acl_for_part_table(_table_name text, _part_table_name text) IS 'Генерируем запрос на права для партиционированной таблицы';
