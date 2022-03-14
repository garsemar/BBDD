/* Activitat 1 */
/* Exercici 1 */
--  Crea un bloc que mostri el nom del departament al que pertany l’empleada Pat Fay.
do $$
declare
    nom_d departments.department_name%type;
begin
    select department_name
    into nom_d
    from departments join employees e on departments.department_id = e.department_id
    where first_name like 'Pat' and last_name like 'Fay';

    raise notice '%', nom_d;
end;
    $$ language plpgsql;

/* Exercici 2 */
-- Crea un procediment que introduirem l’id de l’empleat, i que retorni a quina regió pertany.
do $$
declare
    nom_d regions.region_name%type;
begin
    select region_name
    into nom_d
    from regions
    join countries c on regions.region_id = c.region_id join locations l on c.country_id = l.country_id join departments d on l.location_id = d.location_id join employees e on d.department_id = e.department_id
    where employee_id = :emp_id;
    raise notice '%', nom_d;
end;
    $$ language plpgsql;

/* Exercici 3 */
-- Crea un programa que ha de mostrar  per pantalla : HOLA MUNDO
do $$
begin
    raise notice 'Hola Mundo';
end;
    $$ language plpgsql;

/* Exercici 4 */
-- Crea un programa amb dos variables de tipus NUMERIC. Aquestes variables s’ha de tenir un valor inicial de 10.2 i 20.1 respectivament. El bloc ha de sumar aquestes dues variables i mostrar per pantalla ‘LA SUMA TOTAL ÉS: 30.3’
do $$
declare
    num1 numeric = 10.2;
    num2 numeric = 20.1;
    result numeric;
begin
    result = num1 + num2;

    raise notice 'LA SUMA TOTAL ÉS: %', result;
end;
    $$ language plpgsql;

/* Exercici 5 */
do $$
declare
    empl_na employees%rowtype;
    empl_id employees.employee_id%type;
    empl_idM numeric;
begin
        select *
        into empl_na
        from employees;
    loop
        raise notice '%', empl_na.first_name;
    end loop;
end;
$$ language plpgsql;

/* Exercici 6 */
do $$
declare
    percentatge constant numeric(2) := 10;
    var_empl employees%rowtype;
    var_dept departments%rowtype;
    empl_id employees.employee_id%type;
begin

end;
$$ language plpgsql;

create or replace procedure salutacions (varchar) language plpgsql as $$
    begin
        raise notice 'hola %', $1;
    end;
$$;

call salutacions('pepe');

create procedure mostrar_empleat (v_id employees.employee_id%type) language plpgsql as $$
    declare
        var_empl employees%rowtype;
        calcul numeric (10,2) :=1.10;
        result_calul numeric(10,2);
    begin
        select first_name, last_name, salary*calcul
        into var_empl.first_name, var_empl.last_name, result_calul
        from employees
        where employee_id=v_id;
        raise notice 'El nom de l empleat es %, el cognom % i el salari es %', var_empl.first_name, var_empl.last_name, result_calul;
    end;
$$;

call mostrar_empleat(120);

create function suma (num1 numeric, num2 numeric) returns numeric as $$
    declare
        result numeric;
    begin
        result=num1+num2;
        return (result);
    end;
$$ language plpgsql;

do $$
    BEGIN
        raise notice '2 + 2 es %', suma(2, 2);
    end;
$$ language plpgsql;

show datestyle;

/* UF3 RA1 PAC2 */
/* Exercici 1 */
create type ex1R as (
    first_name varchar,
    salary float,
    commission_pct float,
    job_title varchar,
    manager_id numeric
);

create procedure imprimir_dades (cod_emp employees.employee_id%type) language plpgsql as $$
    declare
        res ex1R;
    begin
        select first_name, salary, commission_pct, job_title, manager_id
        into res
        from employees join jobs j on j.job_id = employees.job_id
        where employee_id = cod_emp;

        if res.commission_pct IS NULL
        then
            res.commission_pct := 0;
        end if;

        raise notice 'first_name salary commission_pct job_title manager_id';
        raise notice '% % % % %', res.first_name, res.salary, res.commission_pct, res.job_title, res.manager_id;
    end;
$$;

do $$
    declare
        cod_emp employees.employee_id%type := :id;
        found numeric;
    BEGIN
        select count(employee_id)
        into found
        from employees
        where employee_id = cod_emp;

        if found = 1
        then
            call imprimir_dades(cod_emp);
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'NO EXISTEIX';
    end;
$$ language plpgsql;

/* Exercici 2 */
create type ex2R as (
    first_name varchar,
    salary float,
    commission_pct float,
    job_title varchar,
    manager_id numeric
);

create function retornar_dades (cod_emp employees.employee_id%type) returns ex2R language plpgsql as $$
    declare
        res ex1R;
    begin
        select first_name, salary, commission_pct, job_title, manager_id
        into res
        from employees join jobs j on j.job_id = employees.job_id
        where employee_id = cod_emp;

        if res.commission_pct IS NULL
        then
            res.commission_pct := 0;
        end if;

        return res;
    end;
$$;

do $$
    declare
        cod_emp employees.employee_id%type := :id;
        res ex2R;
        found numeric;
    BEGIN
        select count(employee_id)
        into found
        from employees
        where employee_id = cod_emp;

        if found = 1
        then
            res := retornar_dades(cod_emp);
            raise notice 'first_name salary commission_pct job_title manager_id';
            raise notice '% % % % %', res.first_name, res.salary, res.commission_pct, res.job_title, res.manager_id;
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'NO EXISTEIX';
    end;
$$ language plpgsql;

/* Exercici 3 */
create function comprovar_dept(cod_emp departments.department_id%type) returns boolean language plpgsql as $$
    declare
        found numeric;
    begin
        select count(department_id)
        into found
        from departments
        where department_id = cod_emp;

        if found = 1
        then
            return true;
        else
            return false;
        end if;
    end;
$$;

do $$
    declare
        cod_emp departments.department_id%type := :id;
        res boolean := comprovar_dept(cod_emp);
    BEGIN
        if res
        then
            raise notice 'EXISTEIX DEPARTAMENT';
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'NO EXISTEIX DEPARTAMENT';
    end;
$$ language plpgsql;

/* Exercici 4 */
do $$
    declare
        id numeric := :id;
        depName varchar := :name;
        manId numeric := :manId;
        loc numeric := :loc;
        res boolean;
    BEGIN
        res := comprovar_dept(id);

        if not res
        then
            raise notice 'NO EXISTEIX DEPARTAMENT';
            insert into departments (department_id, department_name, manager_id, location_id)
            values (id, depName, manId, loc);
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'EXISTEIX DEPARTAMENT';
    end;
$$ language plpgsql;

/* Exercici 5 */
do $$
    declare
        cod_emp departments.department_id%type := :id;
        res boolean := comprovar_dept(cod_emp);
    BEGIN
        if res
        then
            update departments
            set department_name = :name, manager_id = :managerId, location_id = :locId
            where department_id = cod_emp;
            raise notice 'Departamento actualizado';
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'No existe el departamento';
    end;
$$ language plpgsql;

/* Exercici 6 */
create function comprovar_emp(cod_emp employees.employee_id%type) returns boolean language plpgsql as $$
    declare
        found numeric;
    begin
        select count(employee_id)
        into found
        from employees
        where employee_id = cod_emp;

        if found = 1
        then
            return true;
        else
            return false;
        end if;
    end;
$$;

create function nom (cod_emp employees.employee_id%type) returns varchar language plpgsql as $$
    declare
        nom employees.first_name%type;
    begin
        select first_name
        into nom
        from employees
        where employee_id = cod_emp;

        return nom;
    end;
$$;

do $$
    declare
        cod_emp employees.employee_id%type := :id;
        res boolean := comprovar_emp(cod_emp);
    BEGIN
        if res
        then
            raise notice '%', nom(cod_emp);
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'No existe';
    end;
$$ language plpgsql;

/* Exercici 7 */
do $$
    declare
        cod_dep departments.department_id%type;
        nom_dep departments.department_name%type;
        res boolean := comprovar_dept(cod_dep);
    begin
        cod_dep := :id;
        select department_name
        into strict nom_dep
        from departments
        where department_id = cod_dep;
        raise notice '%', nom_dep;
        if LEFT(nom_dep, 1) = 'A'
        then
            raise notice 'COMENÇA PER LA LLETRA A.';
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'ERROR: no dades';
        when TOO_MANY_ROWS then
            raise exception 'ERROR: retorna més files';
        when OTHERS then
            raise exception 'ERROR (sense definir)';
    end;
$$ language plpgsql;
