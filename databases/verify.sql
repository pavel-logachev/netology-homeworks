\set ON_ERROR_STOP on
-- Structural checks against the created database, not the input DDL.
DO $$
DECLARE tables_count integer; pk_count integer; fk_count integer;
BEGIN
    SELECT count(*) INTO tables_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname='public' AND c.relkind='r';
    SELECT count(*) FILTER (WHERE contype='p'), count(*) FILTER (WHERE contype='f') INTO pk_count, fk_count
      FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public';
    ASSERT tables_count=7, 'Expected 7 tables';
    ASSERT pk_count=7, 'Expected 7 primary keys';
    ASSERT fk_count=6, 'Expected 6 foreign keys';
    ASSERT (SELECT count(*) FROM information_schema.columns WHERE table_schema='public' AND is_nullable='NO')=20,
      'All 20 columns must be NOT NULL';
    ASSERT (SELECT count(*) FROM information_schema.columns WHERE table_schema='public' AND is_identity='YES')=6,
      'Expected 6 identity columns';
    ASSERT (SELECT format_type(atttypid,atttypmod) FROM pg_attribute WHERE attrelid='public.employees'::regclass AND attname='salary')='numeric(12,2)',
      'Salary type differs';
    ASSERT (SELECT format_type(atttypid,atttypmod) FROM pg_attribute WHERE attrelid='public.employees'::regclass AND attname='hire_date')='date',
      'Hire date type differs';
    ASSERT (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid='public.employee_projects'::regclass AND contype='p')='PRIMARY KEY (employee_id, project_id)',
      'Composite PK differs';
    ASSERT (SELECT count(*) FROM public.employees)=0, 'Verification must leave no imported employees';
    RAISE NOTICE 'PASS: 7 tables, 7 PK, 6 FK, 20 NOT NULL columns, 6 identities, numeric/date, composite PK.';
END $$;
SELECT conrelid::regclass AS table_name, conname, pg_get_constraintdef(oid) AS definition
FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype IN ('p','f') ORDER BY table_name, conname;
