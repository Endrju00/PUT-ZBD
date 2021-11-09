SELECT * FROM INF145221.pracownicy;

--zad2
GRANT SELECT ON PRACOWNICY TO INF145221;

--zad5
UPDATE INF145221.PRACOWNICY
SET placa_pod = 2 * placa_pod; --nie mozna

UPDATE INF145221.PRACOWNICY
SET placa_pod = 2 * placa_pod
WHERE nazwisko = 'MORZY'; --nie mozna

UPDATE INF145221.PRACOWNICY
SET placa_pod = 700; --sukces

--zad6
CREATE SYNONYM patryk_prac FOR INF145221.PRACOWNICY;

UPDATE patryk_prac
SET placa_pod = 800; --sukces

COMMIT;

--zad7
SELECT * FROM patryk_prac; --nie ma przywileju

--zad8
select owner, table_name, grantee, grantor, privilege
from user_tab_privs;

select table_name, grantee, grantor, privilege
from user_tab_privs_made;

select owner, table_name, grantor, privilege
from user_tab_privs_recd;

select owner, table_name, column_name, grantee, grantor, privilege
from user_col_privs;

select table_name, column_name, grantee, grantor, privilege
from user_col_privs_made;

select owner, table_name, column_name, grantor, privilege
from user_col_privs_recd;

--zad9
UPDATE patryk_prac
SET placa_pod = 1000; --niepowodzenie

UPDATE INF145221.PRACOWNICY
SET placa_pod = 1000; --niepowodzenie

--zad10
CREATE ROLE ROLA_145358;
GRANT SELECT, UPDATE ON PRACOWNICY TO ROLA_145358;

--zad11
GRANT ROLA_145358 TO INF145221;

SELECT * FROM INF145221.PRACOWNICY;

SET ROLE ROLA_145221 IDENTIFIED BY password123; --hasło

select granted_role, admin_option from user_role_privs
where username = 'INF145358';
select role, owner, table_name, column_name, privilege
from role_tab_privs;

--zad12
SELECT * FROM INF145221.PRACOWNICY;



