/*
--Od z28 wstęp do zapytań skorelowanych

--z25
-- 2:
SELECT K.kierunek_id, nazwa, s_ects, X.uzysk_ECTS
FROM kierunki K 
LEFT JOIN 
	-- 1: 
	(SELECT student_id, kierunek_id, SUM(ECTS) Uzysk_ECTS
	FROM zaliczenia Z INNER JOIN przedmioty P ON Z.przedmiot_id=P.przedmiot_id
	AND wynik LIKE 'Z%'
	GROUP BY student_id, kierunek_id) X
-- 3:
ON X.kierunek_id=K.kierunek_id
AND K.s_ects<=X.uzysk_ECTS


--z26 - AVG, MAX
-- 2:
SELECT K.kierunek_id, nazwa, s_ects, AVG(X.uzysk_ECTS) Śr, MAX(X.uzysk_ects)
FROM kierunki K 
LEFT JOIN 
	-- 1: 
	(SELECT student_id, kierunek_id, SUM(ECTS) Uzysk_ECTS
	FROM zaliczenia Z INNER JOIN przedmioty P ON Z.przedmiot_id=P.przedmiot_id
	AND wynik LIKE 'Z%' AND TO_CHAR(data_zal, 'YYYY')='2019'
	GROUP BY student_id, kierunek_id) X
-- 3:
ON X.kierunek_id=K.kierunek_id
GROUP BY K.kierunek_id, nazwa, s_ects


!!! CREATE VIEW BFZ AS
--z26 - Pierwszy i ostatni element
-- Tworzenie widoku/perspektywy - ułatwienie zapytań
-- 2:
SELECT K.kierunek_id, nazwa, s_ects, AVG(X.uzysk_ECTS) Śr, MAX(X.uzysk_ects)
FROM kierunki K 
LEFT JOIN 
	-- 1: 
	(SELECT student_id, kierunek_id, SUM(ECTS) Uzysk_ECTS
	FROM zaliczenia Z INNER JOIN przedmioty P ON Z.przedmiot_id=P.przedmiot_id
	AND wynik LIKE 'Z%' AND TO_CHAR(data_zal, 'YYYY')='2019'
	GROUP BY student_id, kierunek_id) X
-- 3:
ON X.kierunek_id=K.kierunek_id
GROUP BY K.kierunek_id, nazwa, s_ects

-> SELECT * FROM BFZ


--używanie widoku
--3:
SELECT Y.*, Z.*
FROM (
	--2:
	SELECT rok, kierunek_id, AVG(US) Śr
	FROM (
		--1:
		SELECT TO_CHAR(data_zal, 'YYYY') Rok, kierunek_id, student_id, SUM(ECTS) US
		FROM zaliczenia Z INNER JOIN przedmioty P ON Z.przedmiot_id=P.przedmiot_id
		AND Z.wynik LIKE 'Z%'
		GROUP BY TO_CHAR(data_zal, 'YYYY'), kierunek_id, student_id
		) X
	GROUP BY kierunek_id, rok
	) Y
RIGHT JOIN BFZ Z ON Y.kierunek_id=Z.kierunek_id AND Y.Śr=Z.Śr


--z27
--2: dołóż informacje o zaliczeniach do kierunku
SELECT X.*, Z.*
FROM (
	--1: sprawdź informacje o kierunku
	SELECT kierunek_id, nazwa
	FROM kierunki
	WHERE nazwa LIKE 'Gry%'
	) X
INNER JOIN zaliczenia Z ON Z.kierunek_id=X.kierunek_id

--3: wyciągnij potrzebne informacje (Z.* nie jest już potrzebny)
SELECT X.*, MIN(data_zal) Pierwszy, MAX(data_zal) Ostatni
FROM (
	SELECT kierunek_id, nazwa
	FROM kierunki
	WHERE nazwa LIKE 'Gry%'
	) X
INNER JOIN zaliczenia Z ON Z.kierunek_id=X.kierunek_id
GROUP BY X.kierunek_id, X.nazwa


--Zapytania skorelowane
--z28
--1: znajdź zaliczenia w danym miesiącu danego roku
SELECT TO_CHAR(data_zal, 'YYYY-MM') Okres, COUNT(*) LZ
FROM zaliczenia Z
GROUP BY TO_CHAR(data_zal, 'YYYY-MM')
ORDER BY 2 DESC --sortuj po 2 kolumnie

--2: zrób z tego X i policz max po liczbie zaliczeń
SELECT MAX(LZ)
FROM 
	(SELECT TO_CHAR(data_zal, 'YYYY-MM') Okres, COUNT(*) LZ
	FROM zaliczenia Z
	GROUP BY TO_CHAR(data_zal, 'YYYY-MM')
	--sortuj po 2 kolumnie
	ORDER BY 2 DESC ) X

--3: skoro masz wynik to sprawdź czy nie było takiego samego wyniku w wielu miesiącach
SELECT TO_CHAR(data_zal, 'YYYY-MM') Okres, COUNT(*) LZ
FROM zaliczenia Z
GROUP BY TO_CHAR(data_zal, 'YYYY-MM')
HAVING COUNT(*)=(
	SELECT MAX(LZ)
	FROM 
		(SELECT TO_CHAR(data_zal, 'YYYY-MM') Okres, COUNT(*) LZ
		FROM zaliczenia Z
		GROUP BY TO_CHAR(data_zal, 'YYYY-MM')
		--sortuj po 2 kolumnie
		ORDER BY 2 DESC ) X
)


--z29 - w pełni skorelowane zapytanie
--1: znajdź zakiczenia na dany przedmiot i wykladowce
SELECT W.wykladowca_id, W.nazwisko, W.imie, P.przedmiot_id, P.nazwa, COUNT(*) LZ
FROM zaliczenia Z 
	INNER JOIN wykladowcy W ON W.wykladowca_id=Z.wykladowca_id 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
WHERE P.przedmiot_id=1
GROUP BY W.nazwisko, W.imie, W.wykladowca_id, P.przedmiot_id
--2: filtruj 
HAVING COUNT(*)=(
	--3: weź maks z zaliczeń10:04 27.11.2023
	SELECT MAX(LZ) FROM (
		SELECT wykladowca_id, przedmiot_id, COUNT(*) LZ
		FROM Zaliczenia
		WHERE przedmiot_id=1
		GROUP BY wykladowca_id, przedmiot_id
	)
)
ORDER BY P.nazwa DESC

-- where źle filtruje (nie dynamicznie)

--poprawienie
SELECT W.wykladowca_id, W.nazwisko, W.imie, P.przedmiot_id, P.nazwa, COUNT(*) LZ
FROM zaliczenia Z 
	INNER JOIN wykladowcy W ON W.wykladowca_id=Z.wykladowca_id 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
-- WHERE P.przedmiot_id=3
GROUP BY W.nazwisko, W.imie, W.wykladowca_id, P.przedmiot_id
HAVING COUNT(*)=(
	SELECT MAX(LZ) FROM (
		SELECT wykladowca_id, przedmiot_id, COUNT(*) LZ
		FROM Zaliczenia
		WHERE przedmiot_id=P.przedmiot_id
		GROUP BY wykladowca_id, przedmiot_id
	) X
	GROUP BY P.przedmiot_id
)
ORDER BY P.nazwa DESC

-- z pierwszego GROUP BY mogę korzystać z pól wymienionych w nim do filtrowania w HAVING!


--z30 - to nie jest zapytanie skorelowane
--3: dołóż pozostałe dane
SELECT Y.*, S.nazwisko, S.imie, K.nazwa
	--2: dołóż kierunek i studenta
FROM (SELECT Z.kierunek_id, Z.student_id, X.MD
	FROM Zaliczenia Z INNER JOIN (
		--1: znajdź minimalną datę zaliczenia (to bd pierwsze zal)
		SELECT kierunek_id, MIN(data_zal) MD
		FROM zaliczenia
		GROUP BY kierunek_id) X
	ON Z.kierunek_id=X.kierunek_id AND Z.data_zal=X.MD) Y
RIGHT JOIN kierunki K ON Y.kierunek_id=K.kierunek_id
RIGHT JOIN studenci S ON Y.student_id=S.student_id

--z31 -- skorelowane (zobacz co jest w having)
--3: obuduj 1.
SELECT S.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa, SUM(P.ECTS) SP
FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
	INNER JOIN kierunki K ON Z.kierunek_id=K.kierunek_id
--ograniczenie zeby nie czekac na wynik
WHERE K.kierunek_id=1
GROUP BY s.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa
--habing po max
HAVING SUM(ECTS)=(
	--2: skopiuj 1. do MAX w 2.
	SELECT MAX(SP)
	FROM (
		--1:
		SELECT S.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa, SUM(P.ECTS) SP
		FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
			INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
			INNER JOIN kierunki K ON Z.kierunek_id=K.kierunek_id
		--ograniczenie zeby nie czekac na wynik
		WHERE K.kierunek_id=1
		GROUP BY s.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa) X
	)
--to zapytanie jest odporne na zmiane aliasów w dużym SELECT

--zmiana na wszystkie kierunki (WHERE w obu SELECT)
SELECT S.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa, SUM(P.ECTS) SP
FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
	INNER JOIN kierunki W ON Z.kierunek_id=W.kierunek_id
--ograniczenie zeby nie czekac na wynik
GROUP BY s.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa
HAVING SUM(ECTS)=(
	SELECT MAX(SP)
	FROM (
		SELECT S.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa, SUM(P.ECTS) SP
		FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
			INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
			INNER JOIN kierunki K ON Z.kierunek_id=K.kierunek_id
		--ograniczenie zeby nie czekac na wynik
		WHERE K.kierunek_id=W.kierunek_id
		GROUP BY s.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa) X
	GROUP BY W.kierunek_id
	)

--teraz mamy N*N operacji (SELECT*HAVING)
--jak to uprościć? - znajdź maks sam i nałóż go do having
SELECT S.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa, SUM(P.ECTS) SP
FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
	INNER JOIN kierunki W ON Z.kierunek_id=W.kierunek_id
--ograniczenie zeby nie czekac na wynik
WHERE W.kierunek_id=1
GROUP BY s.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa
HAVING SUM(ECTS)=30
-- (
-- 	SELECT MAX(SP)
-- 	FROM (
-- 		SELECT S.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa, SUM(P.ECTS) SP
-- 		FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
-- 			INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
-- 			INNER JOIN kierunki K ON Z.kierunek_id=K.kierunek_id
-- 		--ograniczenie zeby nie czekac na wynik
-- 		WHERE K.kierunek_id=W.kierunek_id
-- 		GROUP BY s.student_id, S.nazwisko, S.imie, K.kierunek_id, K.nazwa) X
-- 	GROUP BY W.kierunek_id
-- 	)

--wykorzystanie widoku i parametru (wszystkich studentow i ich punktow)
WITH X AS (SELECT S.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa, SUM(P.ECTS) SP
FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
	INNER JOIN kierunki W ON Z.kierunek_id=W.kierunek_id
GROUP BY s.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa
)

SELECT * FROM X
	INNER JOIN (SELECT kierunek_id, MAX(SP) msp FROM X GROUP BY kierunek_id) Y ON X.kierunek_id=Y.kierunek_id AND X.SP=Y.msp
--złożoność N+1 - uniknęliśmy korelacji


--tutaj bierzesz tylko N i z pamięci dokładasz kolejne zapisane już wcześniej N
--następnie odrzucasz te które są mniejsze (zostają nawiększe)
WITH X AS (SELECT S.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa, SUM(P.ECTS) SP
FROM studenci S INNER JOIN zaliczenia Z ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id AND Z.wynik LIKE 'Z%'
	INNER JOIN kierunki W ON Z.kierunek_id=W.kierunek_id
--ograniczenie zeby nie czekac na wynik
-- WHERE W.kierunek_id=1
GROUP BY s.student_id, S.nazwisko, S.imie, W.kierunek_id, W.nazwa)

SELECT * FROM X EXCEPT
SELECT X.* FROM X INNER JOIN X Y ON X.kierunek_id=Y.kierunek_id AND X.SP<Y.SP


--z31/32
WITH X AS (SELECT S.student_id, nazwisko, imie, wynik, COUNT(*) LZN
FROM Zaliczenia Z INNER JOIN Studenci S ON Z.student_id=S.student_id 
AND Z.wynik NOT LIKE 'Z%'
GROUP BY S.student_id, z.wynik)

SELECT * FROM X EXCEPT 
SELECT X.* FROM X INNER JOIN X Y ON X.LZN<Y.LZN

*/
