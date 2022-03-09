/* Part A */
/* Exercici 1 */
create table Provincia (
    cod_prov serial,
    nom varchar(20) not null,
    ca varchar(20) not null,

    constraint pk_provincia primary key(cod_prov),
    constraint upper check ( nom = upper(nom) )
);

create table Municipi (
    cod_mun serial,
    Nom_mun varchar(20),
    cod_prov int,

    constraint pk_municipi primary key(cod_mun, cod_prov),
    constraint fk_municipi foreign key(cod_prov) references Provincia(cod_prov)
);

create table Cadastre (
    cod_cadastre serial,
    Finca numeric(10) not null,
    full_pla varchar(40) not null,
    data_const date not null default current_date,
    carrer varchar(80) not null,
    nombre numeric(4) not null,

    constraint pk_cadastre primary key(cod_cadastre),
    constraint fk_cadastreC foreign key(carrer) references vivenda(carrer),
    constraint fk_cadastreN foreign key(nombre) references vivenda(nombre)
);

/* Exercici 2 */
alter table provincia drop column ca;

/* Exercici 3 */
alter table provincia add column ca varchar(20) not null;
select * from Municipi;
/* Exercici 8 */
begin;
drop table provincia cascade;
rollback;
/* Exercici 10 */
create view quantitat_persones as
    select count(*)
    from casaparticular
    group by carrer, nombre;

/* Exercici 11 */
create index ex11 on persona(carrer, nombre, dni);
-- He decidit indexar aquestes columnes perque crec que son importants i et dona informacio general sobre les cases i quanta gent viu per cada una

/* Exercici 12 */
create sequence seq_exam
    start with 1000
    increment by 1
    no minvalue
    no maxvalue
    no cycle;

/* Exercici 13 */
insert into municipi(nom_mun, cod_prov) values ('Municipi', 2);

/* Exercici 14 */
alter table provincia drop constraint upper;
insert into provincia (nom, ca) values ('gracia', 'gracia');
alter table provincia add constraint upper check ( nom = upper(nom) );
-- No et deixa tornar activar la restriccio perque hi ha una fila que esta en minuscula



/* Part B */
/* Exercici 1 */
select v.carrer, v.nombre, v.nom_zona, sum(metres)
from vivenda v join pis p on v.carrer = p.carrer
where escala = 'A' and planta = '1' and porta = '2'
group by v.carrer, v.nombre, v.nom_zona, metres
order by metres desc limit 1;

/* Exercici 2 */
select count(c.carrer), c.carrer, c.nombre, c.dni_cp
from casaparticular c join vivenda v on v.carrer = c.carrer and v.nombre = c.nombre
where v.nom_zona = 'BOBADILLA' and metres_c < (
    select metres_p from pis join vivenda v on pis.carrer = v.carrer where v.nom_zona='CERRILLO DE MARACENA' order by metres_p desc limit 1)
group by c.carrer, c.nombre;

/* Exercici 3 */
select count(*), pis.carrer, pis.nombre, escala, planta, porta
from pis join vivenda v on pis.carrer = v.carrer
where planta >= 8 and nom_zona = 'GRAN VÍA_CATEDRAL' and (v.nombre % 2) = 0 and 2 < (select count(*) from pis group by carrer, nombre order by 1 desc limit 1)
group by nom_zona, pis.carrer, pis.nombre, escala, planta, porta;

/* Exercici 4 */
select count(*) as "Quantitat_persones", codi_postal, carrer, nombre
from vivenda
where metres = (select metres_p from pis order by metres_p desc limit 1)
group by carrer, nombre;

do $$
declare
    v_deptname employee%rowtype;
begin
    select nom_persona
    into v_deptname
    from persona;
    raise notice 'Hola %', v_deptname;
end; $$ language plpgsql;

/* Activitat 1 */
/* Exercici 3 */
do $$
begin
    raise notice 'Hola Mundo';
end;
    $$ language plpgsql;

/* Exercici 4 */
do $$
declare
    num1 numeric (3,1):=10.2;
    num2 numeric (3,1):=20.1;
    result numeric (4,2);
begin
    result = num1+num2;
    raise notice 'El resultat de sumar % i % es %', num1, num2, result;
end;
$$ language plpgsql;

/* Exercici 1 */
select cap.dni_c, p.nom_persona, p.cognoms_persona, p.dni_c, count(*)
from persona p join persona cap on cap.dni_c = p.dni
group by cap.dni_c, p.nom_persona, p.cognoms_persona, p.dni_c;

/* Exercici 4 */
select count(dni) as "zona_mes_poblada"
from vivenda
inner join persona p on vivenda.carrer = p.carrer and vivenda.nombre = p.nombre
group by nom_zona
having count(dni) in (select max(a) from (select count(dni) as a
from vivenda inner join persona p2 on vivenda.carrer = p2.carrer and vivenda.nombre = p2.nombre
group by nom_zona) as b)
union
select count(dni) as "zona_menys_poblada"
from vivenda
inner join persona p on vivenda.carrer = p.carrer and vivenda.nombre = p.nombre
group by nom_zona
having count(dni) in (select min(a) from (select count(dni) as a
from vivenda inner join persona p2 on vivenda.carrer = p2.carrer and vivenda.nombre = p2.nombre
group by nom_zona) as b);
