/*
Zadania z sql - przypomnienie składni i działania kwerend

 aliasy -> np. FROM studenci S lub table_name AS alias_name
odwołanie sie do tabel -> SELECT nazwa, tabela.nazwa_kolumny (jak używasz aliasu to alias_name.nazwa_kolumny)


Kolejnosc wykonywania:
from 
where
order
select

SELECT:
	DISTINCT (np. select distinct)
	nazwy_kolumn
	
FROM: 
	nazwy_tabeli
	JOIN (itd)
	
WHERE:
	-> UPPER(nazwa_tabeli.miasto) = UPPER('cOś_w_INpuT') (wszystkie litery do dużych/małych)
	-> LOWER -||-
	-> LIKE (np. 'Z%')
AND:
	dodatkowe grupowanie - iloczyn karteznański (cos jak JOIN)
GROUP BY:
	
HAVING:
	
ORDER BY - sortowanie:
	-> DECS
	-> ASC

Zmiana formatowania! (funkcja to_char)
np SELECT data_zal, TO_CHAR(data_zal, 'YYYY/Month/DD')
*/
-- zad. 4
SELECT S.student_id, P.przedmiot_id, data_zal, P.nazwa, S.nazwisko, S.imie
FROM zaliczenia, przedmioty AS P, studenci AS S
WHERE S.student_id='0000049'
AND zaliczenia.przedmiot_id=P.przedmiot_id
AND zaliczenia.student_id=S.student_id

-- lub

SELECT S.student_id, P.przedmiot_id, data_zal, P.nazwa, S.nazwisko, S.imie
FROM zaliczenia AS Z INNER JOIN przedmioty AS P ON P.przedmiot_id=Z.przedmiot_id INNER JOIN studenci AS S ON S.student_id=Z.student_id
AND S.student_id='0000049'
-- -> to jest szybsze

-- Błędna formuła
SELECT S.student_id, P.przedmiot_id, data_zal, TO_CHAR(data_zal, 'YYYY/Month/DD') Data2, P.nazwa, S.nazwisko, S.imie
FROM zaliczenia AS Z INNER JOIN przedmioty AS P ON P.przedmiot_id=Z.przedmiot_id INNER JOIN studenci AS S ON S.student_id=Z.student_id
WHERE S.student_id='0000049'
ORDER BY TO_CHAR(data_zal, 'Month/YY/DD') -> sortowanie ALFABETYCZNE ciągu znaków (nie daty)

-- zad. 5
SELECT W.wykladowca_id, nazwisko||' '||imie AS wykladowca, P.przedmiot_id
FROM wykladowcy W, Przedmioty P, Zaliczenia Z 
WHERE W.wykladowca_id=Z.wykladowca_id
AND Z.przedmiot_id=P.przedmiot_id
AND W.wykladowca_id='0009'

-- zad. 7
SELECT DISTINCT S.student_id, S.nazwisko, S.imie, P.nazwa, TO_CHAR(data_zal, 'Day')
FROM Zaliczenia Z INNER JOIN studenci S ON S.student_id=Z.student_id
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
WHERE S.student_id='0000060' 

-- zad. 8
SELECT S.imie, S.nazwisko, P.nazwa, Z.data_zal
FROM zaliczenia Z 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	INNER JOIN studenci S ON S.student_id=Z.student_id
WHERE Z.data_zal BETWEEN TO_DATE('20 April 2019','DD Month YYYY') AND TO_DATE('20 May 2020', 'DD Month YYYY')

SELECT S.imie, S.nazwisko, P.nazwa, Z.data_zal
FROM zaliczenia Z 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	INNER JOIN studenci S ON S.student_id=Z.student_id
/*
WHERE Z.data_zal BETWEEN TO_DATE('20 April 2019','DD Month YYYY') AND TO_DATE('20 May 2020', 'DD Month YYYY')
*/
WHERE TO_CHAR(data_zal, 'DD Month YYYY') BETWEEN '00April 2019' AND '20 Zay 2029'
-- -> to błąd

-- zad. 9
SELECT S.imie, S.nazwisko, P.nazwa, Z.data_zal, P.przedmiot_id, P.nazwa, Z.wynik
FROM zaliczenia Z 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	INNER JOIN studenci S ON S.student_id=Z.student_id
WHERE (S.student_id='0000061' OR S.student_id='0500323')  AND wynik LIKE 'Z%'

-- lub uproszczone -> bez orania

SELECT S.imie, S.nazwisko, P.nazwa, Z.data_zal, P.przedmiot_id, P.nazwa, Z.wynik
FROM zaliczenia Z 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	INNER JOIN studenci S ON S.student_id=Z.student_id
WHERE S.student_id IN ('0000061','0500323') AND wynik LIKE 'Z%'

-- zad. 10
SELECT S.student_id, S.imie, S.nazwisko
FROM studenci S EXCEPT

SELECT DISTINCT S.student_id, S.imie, S.nazwisko
FROM zaliczenia Z 
	INNER JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	INNER JOIN studenci S ON S.student_id=Z.student_id
WHERE P.przedmiot_id=7

-- lub

-- działanie lfet/right join - bierze z jednej lub drugiej tabeli i dopasowywuje pozostałe pola (szybszy niż wyżej)

SELECT DISTINCT S.student_id, S.imie, S.nazwisko, Z.przedmiot_id
FROM zaliczenia Z 
	RIGHT JOIN studenci S ON S.student_id=Z.student_id
	AND Z.przedmiot_id=7
WHERE Z.przedmiot_id IS NULL

-- lub budować sql etapami

/*2.*/ SELECT student_id, nazwisko, imie
FROM studenci
WHERE student_id /*3.*/(NOT) IN

/*1.*/ (SELECT DISTINCT student_id
FROM zaliczenia
WHERE przedmiot_id=7)

-- zad. 11
/*2.*/ SELECT DISTINCT kierunek_id, nazwa
FROM kierunki
WHERE kierunek_id /*3.*/ NOT IN

/*1.*/ (SELECT DISTINCT kierunek_id
FROM zaliczenia)

-- lub

SELECT DISTINCT K.kierunek_id, nazwa, Z.kierunek_id
FROM zaliczenia Z RIGHT JOIN kierunki K ON K.kierunek_id=Z.kierunek_id
WHERE Z.kierunek_id IS NULL

-- zad. 12
SELECT imie, nazwisko, wykladowca_id
FROM wykladowcy
WHERE nazwisko LIKE 'B%'

-- zad. 13
SELECT przedmiot_id, TO_CHAR(data_zal, 'YYYY Month'), kierunek_id
FROM zaliczenia
WHERE TO_CHAR(data_zal, 'YYYY FMMonth')='2020 April'