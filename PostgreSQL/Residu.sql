/* Exercici 1 */
create type ex1R as (
    ciutatD varchar,
    quantT numeric
);

create or replace function ciutat_desti (dayI date, dayM date) returns ex1R language plpgsql as $$
    declare
        res ex1R;
    begin
        select ciutat_desti, sum(quantitat_trasllat)
        into res
        from trasllat join desti d on d.cod_desti = trasllat.cod_desti
        where data_arribada > dayI and data_arribada < dayM
        group by ciutat_desti
        having sum(quantitat_trasllat) = (select min(a) from (select sum(quantitat_trasllat) as a from trasllat
        join desti d on d.cod_desti = trasllat.cod_desti
        where data_arribada > dayI and data_arribada < dayM
        group by ciutat_desti) as a);
        return res;
    end;
$$;

create or replace procedure printar_ciutat_desti(a date, b date) language plpgsql as $$
    declare
        res ex1R := ciutat_desti(a, b);
    begin
        raise notice 'La ciutat de destí que menys residus ha rebut durant el periode comprés entre % i %, és % i la quantitat és %', a, b, res.ciutatd, res.quantt;
    end;
$$;

call printar_ciutat_desti('2016-01-01', '2017-01-01');

/* Exercici 2 */
create or replace procedure emp_prod_max() language plpgsql as $$
    declare
        empName residu%rowtype;
        nomEmp empresaproductora.nom_empresa%type;
    begin
        select nom_empresa, residu.nif_empresa, toxicitat, sum(quantitat_residu)
        into nomEmp, empName.nif_empresa, empName.toxicitat, empName.quantitat_residu
        from residu join empresaproductora e on e.nif_empresa = residu.nif_empresa
        group by residu.nif_empresa, nom_empresa, toxicitat
        having sum(quantitat_residu) = (select max(a) from (select sum(quantitat_residu) as a from residu
        join empresaproductora e on e.nif_empresa = residu.nif_empresa
        group by residu.nif_empresa, nom_empresa, toxicitat) as a);

        raise notice 'L’empresa productura que més residus genera és %, %, la toxicitat d’aquest productes és % la quantitat %', empName.nif_empresa, nomEmp, empName.toxicitat, empName.quantitat_residu;
    end;
$$;

call emp_prod_max();

/* Exerici 3 */
create type ex3R as (
    nif_empTr varchar,
    nom_empTr varchar,
    km numeric
);

create or replace function emp_transportistat(dayI date, dayM date) returns ex3R language plpgsql as $$
    declare
        res ex3R;
    begin
        select empresatransportista.nif_emptransport, nom_emptransport, sum(kms)
        into res
        from empresatransportista join trasllat_empresatransport te on empresatransportista.nif_emptransport = te.nif_emptransport
        where data_enviament > dayI and data_enviament < dayM
        group by empresatransportista.nif_emptransport, nom_emptransport
        having sum(kms) = (select max(a) from (select sum(kms) as a from empresatransportista
        join trasllat_empresatransport te on empresatransportista.nif_emptransport = te.nif_emptransport
        where data_enviament > dayI and data_enviament < dayM
        group by empresatransportista.nif_emptransport, nom_emptransport) as a);
        return res;
    end;
$$;

create or replace procedure printar_emp_transportista(dayI date, dayM date) language plpgsql as $$
    declare
        res ex3R := emp_transportistat(dayI, dayM);
    begin
        raise notice 'L’empresa amb CIF % i amb nom %, ha recorregut % de kms durant el període %, %', res.nif_empTr, res.nom_empTr, res.km, dayI, dayM;
    end;
$$;

call printar_emp_transportista('2016-01-01', '2017-01-01');

/* Exercici 4 */
create type ex4R as (
    nif_empresa varchar,
    nom_empresa varchar,
    nom_desti varchar,
    ciutat_desti varchar,
    envas varchar,
    tractament varchar,
    quantitat_residu numeric
);

create or replace function tract_residu(tipTrac trasllat.tractament%type) returns ex4R language plpgsql as $$
    declare
        res ex4R;
    begin
        select e.nif_empresa, nom_empresa, nom_desti, ciutat_desti, envas, tractament, sum(r.quantitat_residu)
        into res
        from trasllat join desti d on d.cod_desti = trasllat.cod_desti join residu r on r.nif_empresa = trasllat.nif_empresa and r.cod_residu = trasllat.cod_residu join empresaproductora e on trasllat.nif_empresa = e.nif_empresa
        where tractament = tipTrac
        group by e.nif_empresa, nom_desti, ciutat_desti, envas, tractament
        having sum(r.quantitat_residu) = (select max(a) from (select sum(r.quantitat_residu) as a from trasllat
        join desti d on d.cod_desti = trasllat.cod_desti join residu r on r.nif_empresa = trasllat.nif_empresa and r.cod_residu = trasllat.cod_residu join empresaproductora e on trasllat.nif_empresa = e.nif_empresa
        where tractament = tipTrac
        group by e.nif_empresa, nom_desti, ciutat_desti, envas, tractament) as a);
        return res;
    end;
$$;

create procedure printar_tract_residu(tipTrac trasllat.tractament%type) language plpgsql as $$
    declare
        res ex4R := tract_residu(tipTrac);
    begin
        raise notice 'L’empresa amb CIF % i amb nom %, ha traslladat al destí % ubicat en % en l’envàs %, el residu amb tractament %', res.nif_empresa, res.nom_empresa, res.nom_desti, res.ciutat_desti, res.envas, res.tractament;
    end;
$$;

call printar_tract_residu('Segregació i lliurament');

/* Exercici 5 */
create type ex5R as (
    codDest varchar,
    ciutatDesti varchar,
    quanT numeric
);

create or replace function quantitat_residus(codDesti trasllat.cod_desti%type, anyo numeric) returns ex5R language plpgsql as $$
    declare
        res ex5R;
    begin
        select trasllat.cod_desti, ciutat_desti, sum(quantitat_trasllat)
        into res
        from trasllat join desti d on d.cod_desti = trasllat.cod_desti
        where trasllat.cod_desti = codDesti and extract( year from data_enviament) = anyo and extract( year from data_arribada) = anyo
        group by trasllat.cod_desti, ciutat_desti;
        return res;
    end;
$$;

create or replace procedure printar_q_residus(codDesti trasllat.cod_desti%type, anyo numeric) language plpgsql as $$
    declare
        res ex5R := quantitat_residus(codDesti, anyo);
    begin
        raise notice 'La quantitat de residus que s’ha traslladat durant l’any % és % i el destí %', anyo, res.quanT, res.ciutatDesti;
    end;
$$;

call printar_q_residus('12', 2016);

/* Llenguatge_Procedural_Part2 */
-- Exercici 1
create type ex1T as (
    nom_emptransport varchar,
    nif_emptransport varchar,
    kms numeric,
    cost numeric
);

create or replace function checkDates(dateIn date, dateFi date) returns boolean language plpgsql as $$
   begin
       if dateIn < dateFi then
           return true;
        else
           return false;
       end if;
   end;
$$;

create or replace procedure dadesEmpTrans(tip_trans varchar, dateIn date, dateFi date) language plpgsql as $$
    declare
        trans cursor for select nom_emptransport, e.nif_emptransport, kms, cost
        from trasllat_empresatransport join empresatransportista e on e.nif_emptransport = trasllat_empresatransport.nif_emptransport
        where data_enviament >= dateIn and data_enviament <= dateFi and tipus_transport = tip_trans;
        res ex1T;
        found numeric;
    begin
        select count(tipus_transport)
        into found
        from trasllat_empresatransport
        where tipus_transport = tip_trans;

        if found >= 1
        then
            if checkDates(dateIn, dateFi)
            then
                for res in trans loop
                    raise notice 'L’empresa %, amb CIF %, ha realitzat % Kms amb un cost % en %, en el periode comprés entre % i %', res.nom_emptransport, res.nif_emptransport, res.kms, res.cost, tip_trans, dateIn, dateFi;
                end loop;
            end if;
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'El departament no existeix';
    end;
$$;

call dadesEmpTrans(:tip_tran, :dateIn, :dateFi);

-- Exercici 2
create type ex2T as (
    nom_constituent varchar,
    nom_empresa varchar,
    nom_desti varchar
);

create or replace procedure infoRes(cod_res numeric, dateIn date, dateFi date) language plpgsql as $$
    declare
        residu cursor for select nom_constituent, nom_empresa, nom_desti
        from residu_constituent
        join constituent c on c.cod_constituent = residu_constituent.cod_constituent
        join residu r on r.nif_empresa = residu_constituent.nif_empresa and r.cod_residu = residu_constituent.cod_residu
        join empresaproductora e on e.nif_empresa = r.nif_empresa
        join trasllat t on e.nif_empresa = t.nif_empresa
        join desti d on d.cod_desti = t.cod_desti
        where data_enviament >= dateIn and data_enviament <= dateFi and r.cod_residu = cod_res;
        res ex2T;
        found numeric;
    begin
        select count(cod_residu)
        into found
        from trasllat_empresatransport
        where cod_residu = cod_res;

        if found >= 1
        then
            if checkDates(dateIn, dateFi)
            then
                for res in residu loop
                    raise notice 'El redisu amb codi %, i amb nom %, ha sigut generat per l’empresa amb nom % i transportat al destí %, en el període comprés entre % i %', cod_res, res.nom_constituent, res.nom_empresa, res.nom_desti, dateIn, dateFi;
                end loop;
            end if;
        else
            raise exception NO_DATA_FOUND;
        end if;
    exception
        when NO_DATA_FOUND then
            raise exception 'El residu no existeix';
    end;
$$;

call infoRes(:cod_res, :dateIn, :dateFi);

-- Exercici 3
create or replace procedure mesTrans(dateIn date, dateFi date) language plpgsql as $$
    declare
        emp cursor for select nif_emptransport, cost, tipus_transport, count(*)
        from trasllat_empresatransport
        where data_enviament between dateIn::date and dateFi::date
        group by nif_emptransport, cost, tipus_transport
        having count(*) = (select max(a) from (select count(*) as a from trasllat_empresatransport
        where data_enviament between dateIn::date and dateFi::date
        group by nif_emptransport, cost, tipus_transport) as a);
        res trasllat_empresatransport%rowtype;
    begin
        if checkDates(dateIn, dateFi)
        then
            for res in emp loop
                update trasllat_empresatransport
                set cost = (((10.00*res.cost)/100.00)+res.cost)
                where nif_emptransport = res.nif_emptransport;

                raise notice 'Transport: %, cost original: %, cost despres de laument: %', res.tipus_transport, res.cost, (((10.00*res.cost)/100.00)+res.cost)::int;
            end loop;
        else
            raise exception DATA_EXCEPTION;
        end if;
    exception
        when DATA_EXCEPTION then
            raise exception 'Data incorrecta';
    end;
$$;

call mesTrans(:dateIn, :dateFi);

-- Exercici 4
create or replace function checkInsert(nif_emp varchar, cod_res numeric) returns boolean language plpgsql as $$
    declare
        residu cursor for select nif_empresa, cod_residu from residu;
    begin
        if nif_emp is null or cod_res is null
        then
            return true;
        end if;
        for res in residu loop
            if res.nif_empresa = nif_emp and res.cod_residu = cod_res then
                return true;
            end if;
        end loop;
        return false;
    end;
$$;

create or replace procedure insertRegs(nif_emp varchar, cod_res numeric, tox numeric, quant_res numeric, aa_res text) language plpgsql as $$
    begin
        if checkInsert(nif_emp, cod_res) then
            rollback;
            raise notice 'ERROR';
        else
            insert into residu (nif_empresa, cod_residu, toxicitat, quantitat_residu, aa_residu)
            values (nif_emp, cod_res, tox, quant_res, aa_res);
            commit;
            raise notice 'Afegit amb exit';
        end if;
    end;
$$;

call insertRegs(:nif_empresa, :cod_residu, :toxicitat, :quantitat_residu, :aa_residu)

/* Llenguatge Procedural (A)_Part 3 */
-- Exercici 1
create function quantres() returns trigger language plpgsql as $$
    begin
        if NEW.quantitat_residu < OLD.quantitat_residu then
            raise 'La quantitat nova % no pot ser més petita que la quantitat actual %', NEW.quantitat_residu, OLD.quantitat_residu;
        else
            return NEW;
        end if;
    end;
$$;

create trigger quantres before update
    on residu
	for each row
    execute procedure quantres();

update residu -- No funciona
set quantitat_residu = 2
where nif_empresa = 'A-12000035';

update residu -- Funciona
set quantitat_residu = 260
where nif_empresa = 'A-12000035';

-- Exercici 2
-- B
create function update_dades() returns trigger language plpgsql as $$
    begin
        if NEW.toxicitat < OLD.toxicitat then
            raise 'La quantitat nova % no pot ser més petita que la quantitat actual %', NEW.toxicitat, OLD.toxicitat;
        else
            return NEW;
        end if;
    end;
$$;

create trigger update_dades before update
    on residu
	for each row
    execute procedure update_dades();

update residu -- No funciona
set toxicitat = 2
where nif_empresa = 'A-12000035';

update residu -- Funciona
set toxicitat = 380
where nif_empresa = 'A-12000035';

-- C
create function no_esborrar_dades() returns trigger language plpgsql as $$
    begin
        raise 'No es permet eliminar dades';
    end;
$$;

create trigger no_esborrar_dades before delete
    on residu
	for each row
    execute procedure no_esborrar_dades();

delete from residu -- No funciona
where nif_empresa = 'A-12000035';

-- D
CREATE TABLE canvis (
    timestamp_ TIMESTAMP WITH TIME ZONE default NOW(),
    nom_trigger text,
    tipus_trigger text,
    nivell_trigger text,
    ordre text
);

create or replace function registrar_canvis() returns trigger language plpgsql as $$
    begin
        insert into canvis (nom_trigger, tipus_trigger, nivell_trigger, ordre) VALUES (tg_name, tg_when, tg_level, tg_op);
        return new;
    end;
$$;

create trigger registrar_canvis before insert or update or delete
    on residu
	for each row
    execute procedure registrar_canvis();

insert into residu (nif_empresa, cod_residu, toxicitat, quantitat_residu, aa_residu)
values ('A-12000428', 109, 94, 54, null);

/* Exam preparation */
select nif_empresa, data_enviament
from trasllat_empresatransport
where cost between 35000 and 36500;

select distinct tractament
from trasllat;

select distinct ciutat_emptransport
from empresatransportista
where ciutat_emptransport not like '';

select nif_empresa, cod_residu, tractament, envas
from trasllat
where left(upper(envas), 1) = 'B';

select tipus_transport, nom_emptransport
from trasllat_empresatransport join empresatransportista e on e.nif_emptransport = trasllat_empresatransport.nif_emptransport
where cod_desti = '6' or cod_desti = '7' or cod_desti = '8';

select nif_empresa, nom_empresa, ciutat_empresa
from empresaproductora
where nom_empresa like '_A%' and nom_empresa like '%S' and (ciutat_empresa = 'MÁLAGA' or ciutat_empresa = 'SEVILLA' or ciutat_empresa = 'CÓRDOBA')
order by nom_empresa desc;

select empresaproductora.nif_empresa, nom_empresa, data_enviament
from empresaproductora join trasllat t on empresaproductora.nif_empresa = t.nif_empresa
where data_enviament between '01/01/2016'::date and '03/31/2016'::date;

/* Subconsultes sensilles */
SELECT nif_emptransport, NOM_EMPTRANSPORT
  FROM EMPRESATRANSPORTISTA
  WHERE nif_emptransport IN
     (SELECT DISTINCT trasllat_empresatransport.nif_emptransport
        FROM TRASLLAT_EMPRESATRANSPORT
        WHERE nif_empresa IN
           (SELECT nif_empresa
              FROM EMPRESAPRODUCTORA
              WHERE lower(CIUTAT_EMPRESA) = 'granada' ))
  ORDER BY NOM_EMPTRANSPORT;

select sum(cost) as "Import de trasllats"
from trasllat_empresatransport
where nif_emptransport = 'A-22300282' and nif_empresa = 'A-12000466' and cod_desti = '22' and cost is not null;

select te.nif_emptransport, nom_emptransport
from empresatransportista join trasllat_empresatransport te on empresatransportista.nif_emptransport = te.nif_emptransport
where ciutat_emptransport = 'GRANADA' and cod_desti = (select cod_desti from desti where ciutat_desti = 'BARCELONA')
order by cost desc limit 1;

select nom_emptransport
from empresatransportista
where nif_emptransport in (
    select nif_emptransport
    from trasllat_empresatransport
    where nif_empresa in (
        select nif_empresa
        from empresaproductora
        where ciutat_empresa = 'MADRID'
    )
);

select nom_empresa, empresaproductora.nif_empresa
from empresaproductora join trasllat t on empresaproductora.nif_empresa = t.nif_empresa join residu r on empresaproductora.nif_empresa = r.nif_empresa
where quantitat_trasllat in (
    select max(quantitat_trasllat)
    from trasllat
    where nif_empresa in (
        select nif_empresa
        from residu
        where toxicitat in (
            select max(toxicitat)
            from residu))
) and r.toxicitat = (select max(toxicitat) from residu);

select e.nif_empresa, nom_empresa
from empresaproductora e join residu_constituent rc on e.nif_empresa = rc.nif_empresa
where cod_constituent::varchar like '992%';

select nif_empresa, nom_empresa
from empresaproductora
where nif_empresa in (
    select nif_empresa
    from residu_constituent
    where cod_constituent::varchar like '992%');

select nif_emptransport, nom_emptransport, ciutat_emptransport
from empresatransportista
where nif_emptransport in (
    select nif_emptransport
    from trasllat_empresatransport
    where cod_desti in (
        select cod_desti
        from desti
        where upper(ciutat_desti) = 'BARCELONA'
    ) and cost in (
        select min(cost)
        from trasllat_empresatransport
        where cod_desti in (
            select cod_desti
            from desti
            where upper(ciutat_desti) = 'BARCELONA'
        )
    )
);

select cod_desti, quantitat_trasllat, data_enviament
from trasllat
where extract(year from data_enviament) = 2016 and extract(day from data_enviament) = 1;

select split_part(nom_empresa, ' ', 1)
from empresaproductora;

select nom_empresa, ciutat_empresa
from empresaproductora
where ciutat_empresa like '___I%';

select current_date - max(data_enviament) from trasllat;

/* Subconsultes avançades */
select tipus_transport, count(nif_empresa) as Total_empreses
from trasllat_empresatransport
where data_enviament between '06/15/2016' and '05/17/2017'
group by tipus_transport;

select tipus_transport, sum(kms)
from trasllat_empresatransport
where (extract(month from data_enviament) = 4 or extract(month from data_enviament) = 5) and extract(year from data_enviament) = '2016'
group by tipus_transport;

select ciutat_desti, sum(quantitat_trasllat)
from trasllat join desti d on d.cod_desti = trasllat.cod_desti
where extract(year from data_arribada) = '2016'
group by ciutat_desti
having sum(quantitat_trasllat) in (select max(a) from (select sum(quantitat_trasllat) as a
from trasllat
where extract(year from data_arribada) = '2016'
group by cod_desti) as b);

select nom_emptransport, count(t.nif_empresa)
from trasllat_empresatransport tt join trasllat t on t.nif_empresa = tt.nif_empresa and t.cod_residu = tt.cod_residu and t.data_enviament = tt.data_enviament and t.cod_desti = tt.cod_desti join empresatransportista e on e.nif_emptransport = tt.nif_emptransport
where t.data_enviament between '01/01/2016'::date and '03/31/2016'::date
group by nom_emptransport
having count(t.nif_empresa) in (select max(a) from (select count(t.nif_empresa) as a
from trasllat_empresatransport tt join trasllat t on t.nif_empresa = tt.nif_empresa and t.cod_residu = tt.cod_residu and t.data_enviament = tt.data_enviament and t.cod_desti = tt.cod_desti join empresatransportista e on e.nif_emptransport = tt.nif_emptransport
where t.data_enviament between '01/01/2016'::date and '03/31/2016'::date
group by nom_emptransport) as b);

select nom_empresa, empresaproductora.nif_empresa, sum(quantitat_trasllat) as Residus
from empresaproductora join trasllat t on empresaproductora.nif_empresa = t.nif_empresa join residu r on empresaproductora.nif_empresa = r.nif_empresa
where r.toxicitat = (select max(toxicitat) from residu)
group by nom_empresa, empresaproductora.nif_empresa
having sum(quantitat_trasllat) in (select min(a) from (select sum(quantitat_trasllat) as a
from empresaproductora join trasllat t on empresaproductora.nif_empresa = t.nif_empresa join residu r on empresaproductora.nif_empresa = r.nif_empresa
where r.toxicitat = (select max(toxicitat) from residu)
group by nom_empresa, empresaproductora.nif_empresa) as b);

select nom_emptransport, count(t.nif_empresa)
from trasllat_empresatransport tt join trasllat t on t.nif_empresa = tt.nif_empresa and t.cod_residu = tt.cod_residu and t.data_enviament = tt.data_enviament and t.cod_desti = tt.cod_desti join empresatransportista e on e.nif_emptransport = tt.nif_emptransport
where t.data_enviament between '04/01/2016'::date and '06/30/2016'::date
group by nom_emptransport
having count(t.nif_empresa) in (select min(a) from (select count(t.nif_empresa) as a
from trasllat_empresatransport tt join trasllat t on t.nif_empresa = tt.nif_empresa and t.cod_residu = tt.cod_residu and t.data_enviament = tt.data_enviament and t.cod_desti = tt.cod_desti join empresatransportista e on e.nif_emptransport = tt.nif_emptransport
where t.data_enviament between '04/01/2016'::date and '06/30/2016'::date
group by nom_emptransport) as b);

select ciutat_desti, sum(quantitat_trasllat) as Residu
from desti join trasllat t on desti.cod_desti = t.cod_desti
where extract(year from data_arribada) = 2016
group by ciutat_desti
having sum(quantitat_trasllat) in (select max(a) from (select sum(quantitat_trasllat) as a
from desti join trasllat t on desti.cod_desti = t.cod_desti
where extract(year from data_arribada) = 2016
group by ciutat_desti) as b);

select tractament, max(quantitat_trasllat) as "Max residu", min(quantitat_trasllat) as "Min residu"
from trasllat
group by tractament
