-- PostgreSQL 18. Run in a NEW database: psql -v ON_ERROR_STOP=1 -f schema.sql
-- Only the report's attributes and technical keys; no sample data.
BEGIN;
CREATE TABLE public.department_types (
    department_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (btrim(name) <> '')
);
CREATE TABLE public.positions (
    position_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (btrim(name) <> '')
);
CREATE TABLE public.branches (
    branch_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address text NOT NULL UNIQUE CHECK (btrim(address) <> '')
);
CREATE TABLE public.departments (
    department_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL CHECK (btrim(name) <> ''),
    department_type_id bigint NOT NULL REFERENCES public.department_types(department_type_id),
    UNIQUE (department_type_id, name)
);
CREATE TABLE public.projects (
    project_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE CHECK (btrim(name) <> '')
);
CREATE TABLE public.employees (
    employee_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL CHECK (btrim(full_name) <> ''),
    salary numeric(12,2) NOT NULL CHECK (salary >= 0),
    hire_date date NOT NULL,
    position_id bigint NOT NULL REFERENCES public.positions(position_id),
    department_id bigint NOT NULL REFERENCES public.departments(department_id),
    branch_id bigint NOT NULL REFERENCES public.branches(branch_id)
);
CREATE TABLE public.employee_projects (
    employee_id bigint NOT NULL REFERENCES public.employees(employee_id) ON DELETE CASCADE,
    project_id bigint NOT NULL REFERENCES public.projects(project_id),
    PRIMARY KEY (employee_id, project_id)
);
-- The composite PK already indexes employee_projects.employee_id.
CREATE INDEX departments_type_idx ON public.departments(department_type_id);
CREATE INDEX employees_position_idx ON public.employees(position_id);
CREATE INDEX employees_department_idx ON public.employees(department_id);
CREATE INDEX employees_branch_idx ON public.employees(branch_id);
CREATE INDEX employee_projects_project_idx ON public.employee_projects(project_id);
COMMIT;
