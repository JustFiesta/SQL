-- z32-34 koncowka zapytan skorelowanych
-- rozpoczecie widokow

--z32
-- znajdz studentów z brakiem zaliczeń
-- dodaj dane studentów z tabeli studenci do zbioru z małego SELECT
SELECT S.student_id, nazwisko, imie, LNZ
FROM studenci S INNER JOIN (
	SELECT student_id, COUNT(*) LNZ
	FROM zaliczenia Z WHERE wynik LIKE 'N%'
	GROUP BY student_id
) X ON S.student_id=X.student_id 


--z33
-- mozna uzyc WITH przed największym SELECT, zeby wyciagnac czesc kwerendy wykorzystywanej (perspektywa/widok)
-- stórz korelacje z HAVING COUNT(*) i SELECT MAX(LNZ)
SELECT S.student_id, nazwisko, imie, LNZ
FROM studenci S INNER JOIN (
	SELECT student_id, COUNT(*) LNZ
	FROM zaliczenia Z WHERE wynik LIKE 'N%'
	GROUP BY student_id
	HAVING COUNT(*)=(
		SELECT MAX(LNZ) FROM (
			SELECT student_id, COUNT(*) LNZ
			FROM zaliczenia Z WHERE wynik LIKE 'N%'
			GROUP BY student_id
		)
	)
) X ON S.student_id=X.student_id 


--z34
-- to samo co wyżej
SELECT P.przedmiot_id, nazwa, opis, negatywne_zal
FROM przedmioty P INNER JOIN (
	SELECT przedmiot_id, COUNT(*) negatywne_zal
	FROM zaliczenia Z WHERE wynik LIKE 'N%'
	GROUP BY przedmiot_id
	HAVING COUNT(*)=(
		SELECT MAX(negatywne_zal)
		FROM (
			SELECT przedmiot_id, COUNT(*) negatywne_zal
			FROM zaliczenia Z WHERE wynik LIKE 'N%'
			GROUP BY przedmiot_id
		)
	)
) X ON P.przedmiot_id=X.przedmiot_id



-- TYPY POLECEN SQL:
-> DDL (DATA DEFINITION LANGUAGE) - CREATE/DROP/ALTER/TRUNCATE/COMMENT/RENAME - tworzenie relacyjnej bazy
-> DML (DATA MANIPULATION LANGUAGE) - INSERT/UPDATE/DELETE - włóż/zaktualizuj/usuń
-> DCL (DATA CONTROL LANGUAGE) - GRANT/REVOKE - nadawanie uprawnień
-> DQL (DATA QUERY LANGUAGE) - SELECT


-- tworzenie widokow
CREATE VIEW AS NAZWA_PERSPEKTYWY
AS ... [SQL]


-- z1, z2
-- przyklad uzycia:
CREATE VIEW STUDENCI_SECURE
AS (
	SELECT student_id, nazwisko, imie, miasto, ulica, numer, kod
	FROM studenci S
)

GRANT SELECT ON STUDENCI_SECURE
TO jakikolwiek_login;



-- wieksze zawezenie:
CREATE VIEW STUDENCI_SECURE_RZESZOW
AS (
	SELECT student_id, nazwisko, imie, miasto, ulica, numer, kod
	FROM studenci S
	WHERE miasto="RZESZOW"
)


--z3
-- inny sposob zapisu relacji miedzy tabelami (WHERE)
SELECT S.student_id, nazwisko, imie, K.kierunek_id, K.nazwa, SUM(ects) uzysk_pkt
FROM studenci S, przedmioty P, kierunki K, zaliczenia Z
WHERE S.student_id=Z.student_id AND P.przedmiot_id=Z.przedmiot_id AND K.kierunek_id=Z.kierunek_id AND wynik LIKE 'Z%'
GROUP BY S.student_id, nazwisko, imie, K.kierunek_id, K.nazwa


--z4
SELECT * FROM studenci_ECTS
WHERE uzysk_pkt>=70


--z5
CREATE VIEW WYKLADOWCY_WYNIKI_ZAL AS
SELECT W.wykladowca_id, nazwisko, imie, P.przedmiot_id, P.nazwa, COUNT(*) zaliczenia_ogol, COUNT(CASE wynik WHEN 'Zaliczony' THEN wynik END) zaliczenia_poz, COUNT(CASE WHEN wynik LIKE 'N%' THEN wynik END) zaliczenia_neg
FROM wykladowcy W, przedmioty P, zaliczenia Z
WHERE W.wykladowca_id=Z.wykladowca_id AND P.przedmiot_id=Z.przedmiot_id
GROUP BY W.wykladowca_id, nazwisko, imie, P.przedmiot_id, P.nazwa
ORDER BY nazwisko, imie ASC


--z6
SELECT wykladowca_id, nazwisko, imie, przedmiot_id, nazwa, zaliczenia_neg/zaliczenia_ogol
FROM wykladowcy_wyniki_zal;
||
SELECT SUM(zaliczenia_neg)/SUM(zaliczenia_ogol)
FROM wykladowcy_wyniki_zal


--z6
DROP VIEW nazwa_widoku