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

/* Activitat 3.2.3 */
/* Exercici 1 */
CREATE OR REPLACE FUNCTION controlar_negatiu (salary numeric) RETURNs BOOLEAN language plpgsql as $$
    BEGIN
        IF salary < 0 THEN
            return (FALSE);
        ELSE
            return (TRUE);
        END IF;
    END;
$$;

select controlar_negatiu(100);

-- Solució 1 - Amb FOR
do $$
    declare
        v_sal employees.salary%type:=:sal;
        c1 cursor for select * from employees where salary > v_sal;
    begin
        if (select controlar_negatiu(v_sal)) is true then
            for v_emp in c1 loop
                raise notice 'El codi d usuari % amb nom % té un salari de %, que és mes gran de %',
                    v_emp.employee_id, v_emp.first_name, v_emp.salary, v_sal;
            end loop;
        else
            raise notice 'El salari no pot ser negatiu!';
        end if;
    end;
$$ language plpgsql;

-- Solució 2 -  amb open-fetch-close
do $$
    declare
        c1 cursor for select * from employees where salary > :sal;
        empleats employees%rowtype;
    begin
        if (select controlar_negatiu(:sal)) is true then
            open c1;
                loop
                    fetch c1 into empleats;
                    exit when not found;
                    raise notice 'El codi d usuari % amb nom % té un salari de %, que és mes gran de %',
                        empleats.employee_id, empleats.first_name, empleats.salary, :sal;
                end loop;
            close c1;
        else
            raise notice 'El salari no pot ser negatiu!';
        end if;
end;$$ language plpgsql;

/* Exercici 2 */
create type ex1 as (
    department_name varchar,
    city varchar
);

-- Solució 1 -  amb open-fetch-close
do $$
    declare
        dep cursor for select department_name, city from departments join locations l on l.location_id = departments.location_id;
        res ex1;
    begin
        open dep;
            loop
                fetch dep into res;
                exit when not found;
                raise notice 'Nom departament %, ciutat %', res.department_name, res.city;
            end loop;
        close dep;
    end;
$$ language plpgsql;

-- Solució 2 - Amb FOR
do $$
    declare
        dep cursor for select department_name, city from departments join locations l on l.location_id = departments.location_id;
        res ex1;
    begin
        for res in dep
        loop
            raise notice 'Nom departament %, ciutat %', res.department_name, res.city;
        end loop;
    end;
$$ language plpgsql;

/* Exercici 3 */
do $$
    declare
        emp cursor for select * from employees;
        empleats employees%rowtype;
    begin
        raise notice 'codi nom salari comissió data d’alta';
        open emp;
            loop
                fetch emp into empleats;
                exit when not found;
                raise notice '% % % % %', empleats.employee_id, empleats.first_name, empleats.salary, empleats.commission_pct, empleats.hire_date;
            end loop;
        close emp;
    end;
$$ language plpgsql;

/* Exercici 4 */
create type ex4 as (
    employee_id numeric,
    first_name varchar,
    department_id numeric,
    department_name varchar
);

-- Solució 1 -  amb open-fetch-close
do $$
    declare
        emp cursor for select employee_id, first_name, d.department_id, department_name from employees join departments d on d.department_id = employees.department_id;
        res ex4;
    begin
        raise notice 'employee_id first_name department_id department_name';
        open emp;
            loop
                fetch emp into res;
                exit when not found;
                raise notice '% % % %', res.employee_id, res.first_name, res.department_id, res.department_name;
            end loop;
        close emp;
    end;
$$ language plpgsql;

-- Solució 2 - Amb FOR
do $$
    declare
        emp cursor for select employee_id, first_name, d.department_id, department_name from employees join departments d on d.department_id = employees.department_id;
        res ex4;
    begin
        raise notice 'employee_id first_name department_id department_name';
        for res in emp
        loop
            raise notice '% % % %', res.employee_id, res.first_name, res.department_id, res.department_name;
        end loop;
    end;
$$ language plpgsql;

/* Exercici 5 */
do $$
    declare
        emp cursor(cod_dep numeric) for select employee_id, first_name from employees where department_id = cod_dep;
        res employees%rowtype;
    begin
        raise notice 'employee_id first_name';
        open emp(:id);
            loop
                fetch emp into res;
                exit when not found;
                raise notice '% %', res.employee_id, res.first_name;
            end loop;
        close emp;
    end;
$$ language plpgsql;

/* Exercici 6 */
create table emp_salari_nou as select * from employees;

do $$
    declare
        emp cursor(cod_dep numeric) for select * from emp_salari_nou where department_id = cod_dep;
        res employees%rowtype;
    begin
        open emp(:id);
            loop
                fetch emp into res;
                exit when not found;

                res.salary := (((18*res.salary)/100)+res.salary)::int;

                update emp_salari_nou
                set salary = res.salary
                where employee_id = res.employee_id;

                raise notice 'El nou salari sera: %', res.salary;
            end loop;
        close emp;
    end;
$$ language plpgsql;

/* Exercici 7 */
do $$
    declare
        emp cursor(cod_dep numeric) for select * from employees where department_id = cod_dep;
        res employees%rowtype;
    begin
        open emp(:id);
            loop
                fetch emp into res;
                exit when not found;
                if res.commission_pct is not null then
                    update employees
                    set commission_pct = commission_pct+0.20
                    where employee_id = res.employee_id;
                end if;
            end loop;
        close emp;
    end;
$$ language plpgsql;

/* Exercici 8 */
create table emp_salari_nou as select * from employees;

do $$
    declare
        emp cursor for select * from employees where commission_pct is not null;
        res employees%rowtype;
    begin
        open emp;
            loop
                fetch emp into res;
                exit when not found;

                res.commission_pct := (((18.00*res.commission_pct)/100.00)+res.commission_pct);

                update emp_salari_nou
                set commission_pct = res.commission_pct
                where employee_id = res.employee_id;

                raise notice 'La comissió de l’empleat % s’ha modificat correctament i és %', res.first_name, res.commission_pct;
            end loop;
        close emp;
    end;
$$ language plpgsql;

/* PAC 4 - Transaccions */
/* Exercici 1 */
create or replace procedure insertardept_tran(nom_dep varchar, manager numeric, cod_loc numeric) language plpgsql as $$
    declare
        dep_id numeric;
        manValid numeric;
        locValid numeric;
    begin
        select max(department_id)+10
        into dep_id
        from departments;

        select count(employees.manager_id), count(location_id)
        into manValid, locValid
        from employees join departments d on d.department_id = employees.department_id
        where employees.manager_id = manager and location_id = cod_loc
        group by employees.manager_id, location_id;

        INSERT INTO departments(department_id, department_name, manager_id, location_id) VALUES (dep_id, nom_dep, manager, cod_loc);
        IF manValid is null and locValid is null THEN
            rollback;
            raise notice 'Manager, location not exist';
        ELSE
            COMMIT;
            raise notice 'Department added';
        END IF;
    end;
$$;

call insertardept_tran(:name, :man, :loc);

/* Exercici 2 */
create or replace procedure insertaremp_tran(
    id numeric,
    fName varchar,
    lName varchar,
    mail varchar,
    number varchar,
    hDate date,
    jId varchar,
    sal float,
    commPct float,
    manId numeric,
    depId numeric
) language plpgsql as $$
    declare
        valid numeric;
    begin
        select count(employee_id)
        into valid
        from employees
        where employee_id = id;

        insert into employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
        values (id, fName, lName, mail, number, hDate, jId, sal, commPct, manId, depId);

        if valid != 0
        then
            raise notice 'Empleat ja existent';
            rollback;
        elsif id is null or fName is null or lName is null or mail is null or number is null or hDate is null or jId is null or sal is null
        then
            raise notice 'Un dels camps obligatoris esta buit';
            rollback;
        else
            commit;
        end if;
    end;
$$;

call insertaremp_tran(:employee_id, :first_name, :last_name, :email, :phone_number, :hire_date, :job_id, :salary, :commission_pct, :manager_id, :department_id);

/* Exercici 3 */
create or replace procedure modifremp_tran(dep_id numeric, import numeric, perc numeric) language plpgsql as $$
    declare
        emp cursor for select * from employees where department_id = dep_id;
        res employees%rowtype;
        valid numeric;
    begin
        open emp;
            loop
                fetch emp into res;
                exit when not found;

                if import > 0 and perc > 0
                then
                    valid := ((res.salary*perc)/100);
                    if import > valid
                    then
                        valid := import;
                    end if;
                end if;

                if valid is not null
                then
                    update employees
                    set salary = res.salary + valid
                    where employee_id = res.employee_id;
                else
                    raise notice 'Salario negativo no permitido';
                    return;
                end if;
            end loop;
        close emp;
    end;
$$;

call modifremp_tran(:dep_id, :import, :percentage);

/* Exercici 4 */
create or replace function buscar_emp(cod_emp numeric) returns boolean language plpgsql as $$
    declare
        res numeric;
    begin
        select count(employee_id)
        into res
        from employees
        where employee_id = cod_emp;

        if res != 0 then
            return true;
        end if;
        return false;
    end;
$$;

create or replace procedure borraremp_tran(cod_emp numeric) language plpgsql as $$
    declare
        existEmp boolean := buscar_emp(cod_emp);
    begin
        delete from employees where employee_id = cod_emp;

        if existEmp then
            commit;
        else
            raise notice 'Employee dont exists';
            rollback;
        end if;
    end;
$$;

call borraremp_tran(:id)

/* Activitat 3.3.1 */
-- Exercici 1
CREATE OR REPLACE FUNCTION nom_departament_notnull() RETURNS TRIGGER language plpgsql AS $$
    DECLARE
    BEGIN
	    if NEW.department_name is null then
            return NULL;
        end if;
        RETURN NEW;
    END;
$$;

CREATE TRIGGER nom_departament_notnull BEFORE INSERT
    ON departments
	FOR EACH ROW
    EXECUTE PROCEDURE nom_departament_notnull();

select * from departments;

insert into departments (department_id, department_name, manager_id, location_id)
values (1235, null, 100, 1500);

-- Exercici 2
CREATE OR REPLACE FUNCTION restriccions_emp() RETURNS TRIGGER language plpgsql AS $$
    DECLARE
    BEGIN
        if tg_op = 'INSERT'
        then
            if NEW.salary < 0
            then
                return NULL;
            end if;
            RETURN NEW;
        elseif tg_op = 'UPDATE'
        then
            if NEW.commission_pct is not null
            then
                if NEW.salary > OLD.salary
                then
                    return NEW;
                end if;
            end if;
            return null;
        end if;
    END;
$$;

create trigger restriccions_emp before insert or update
    on employees
	for each row
    execute procedure restriccions_emp();

insert into employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (1230, 'xddddd', 'abc', 'marti@gaw.cm', '123.123.1231', '2022-01-04', 'IT_PROG', 200, null, 100, 90);

update employees
set salary = 6000
where employee_id = 1230;

select * from employees;

-- Exercici 3
CREATE OR REPLACE FUNCTION comissio() RETURNS TRIGGER language plpgsql AS $$
    DECLARE
    BEGIN
        if((NEW.commission_pct*NEW.salary) > NEW.salary) then
            return null;
        end if;
        return NEW;
    END;
$$;

create trigger comissio before insert
    on employees
	for each row
    execute procedure comissio();

select * from employees;

-- Exercici 4
CREATE OR REPLACE FUNCTION errada_modificacio() RETURNS TRIGGER language plpgsql AS $$
    DECLARE
    BEGIN
        if NEW.first_name = OLD.first_name and NEW.employee_id = OLD.employee_id then
            return NEW;
        end if;
        if NEW.salary < ((10.0*OLD.salary)/100.0)+OLD.salary then
            return NEW;
        end if;
        return null;
    END;
$$;

create trigger errada_modificacio before update
    on employees
	for each row
    execute procedure errada_modificacio();

update employees
set salary = 4200
where employee_id = 185;

select * from employees;

-- Exercici 5
create table resauditaremp (
    resultat VARCHAR(200)
);

CREATE OR REPLACE FUNCTION auditartaulaemp() RETURNS TRIGGER language plpgsql AS $$
    DECLARE
    BEGIN
        if tg_op = 'DELETE'
        then
            insert into resauditaremp (resultat) values ('Data i hora: ' || now() || ', Codi empleat: ' || OLD.employee_id || ', Cognom: ' || OLD.last_name);
        elseif tg_op = 'INSERT'
        then
            insert into resauditaremp (resultat) values ('Data i hora: ' || now() || ', Codi empleat: ' || NEW.employee_id || ', Cognom: ' || NEW.last_name);
        end if;
        return null;
    END;
$$;

create or replace function auditartaulaemp2() returns trigger language plpgsql as $$
    begin
        insert into resauditaremp(resultat)
        values (concat(tg_name, '-', tg_when, '-', tg_level, '-', tg_op, '-', now()));
        return null;
    end;
$$;

create trigger auditartaulaemp before insert or delete
    on employees
	for each row
    execute procedure auditartaulaemp2();

select * from resauditaremp;

delete from employees
where employee_id = 1230;

/* Exam preparation */
insert into employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (402, 'Jose', 'Calatayud', 'prova@prova.com', null, now(), 'SA_MAN', 1600, null, null, null);

rollback;

Create table prova (
id numeric(6) primary key,
name varchar(20),
hire_date date,
salary numeric(8,2));

begin;
insert into prova
select employee_id, first_name, hire_date, salary from employees;

select * from prova;
rollback;
