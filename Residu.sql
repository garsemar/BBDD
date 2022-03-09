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


