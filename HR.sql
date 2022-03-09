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

