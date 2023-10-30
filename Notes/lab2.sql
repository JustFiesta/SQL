/* Funkcje agregujące - z13 - z

COUNT(*date kolumny do zliczania*)  - liczy wiersze z podanych kolumn
GROUP BY - umożliwia rozgrupowanie danych i wyświetlenie nazw kolumn


-> inner joiny są kosztowne czasowo, lepiej zawęzić pierwszy zbiór i połączyć go z kolejnym
*/

--z13
-- użycie etykiety (to nie alias!)
-- 1. znajdź podzbiór 
SELECT kierunek_id, przedmiot_id, TO_CHAR(data_zal, 'YYYY FM Month') "Rok i miesiąc"
FROM zaliczenia
WHERE kierunek_id=3
GROUP BY kierunek_id, przedmiot_id, data_zal
-- 2. Sklej pozosatłe
SELECT K.nazwa, K.kierunek_id, P.nazwa, X.*
FROM kierunki K 
	INNER JOIN
		(SELECT kierunek_id, przedmiot_id, TO_CHAR(data_zal, 'YYYY FM Month') "Rok i miesiąc"
		FROM zaliczenia
		WHERE kierunek_id=3
		GROUP BY kierunek_id, przedmiot_id, data_zal) X
	ON K.kierunek_id=X.kierunek_id
	INNER JOIN przedmioty P ON X.przedmiot_id=P.przedmiot_id
WHERE "Rok i miesiąc" LIKE '2020%Ap%'


--z14

SELECT W.imie, W.nazwisko, COUNT(*) Liczba_zal
FROM zaliczenia Z
	INNER JOIN wykladowcy W ON W.wykladowca_id=Z.wykladowca_id
WHERE Z.wykladowca_id='0006'
GROUP BY W.wykladowca_id, Nazwisko, Imie

-- ponad 500 operacji na bazie
-- lub 

/* 1.
SELECT COUNT(*) Liczba_zal
FROM zaliczenia Z
WHERE wykladowca_id='0006'
GROUP BY wykladowca_id -> a wtedy można opakować go w select zewnętrzny i otrzymamy tą samą odpowiedź
*/

-- 2.
SELECT W.wykladowca_id, Imie, Nazwisko, X.Liczba_zal
FROM 
	(SELECT wykladowca_id, COUNT(*) Liczba_zal
	FROM zaliczenia Z
	WHERE wykladowca_id='0006'
	GROUP BY wykladowca_id) X /*60 rekordów - bierze 8 - ale są zagregowane więc 1*/
INNER JOIN Wykladowcy W ON X.wykladowca_id=W.wykladowca_id /*wybiera ten jeden i łączy je z 9 z dużym selectem*/

-- 9 operacji !!!
-- -> koszt czasowy operacji jest ważny

--z15
-- 1. znajdź
/* SELECT kierunek_id, MIN(data_zal) Pierwsza, MAX(data_zal) Ostatnia
FROM zaliczenia
WHERE kierunek_id='1'
GROUP BY kierunek_id */

-- 2. obuduj SELECTEM szczegółowym
SELECT K.nazwa, X.*
FROM
	(SELECT kierunek_id, MIN(data_zal) Pierwsza, MAX(data_zal) Ostatnia
	FROM zaliczenia
	WHERE kierunek_id='1'
	GROUP BY kierunek_id) X
INNER JOIN kierunki K ON K.kierunek_id=X.kierunek_id

--z16
-- 1. Zlicz wszystkie zaliczenia
SELECT S.student_id, S.nazwisko, S.imie, COUNT(*)
FROM studenci S 
	INNER JOIN zaliczenia Z ON Z.student_id=S.student_id
WHERE S.student_id='0500324' AND Z.wynik='Zaliczony'
GROUP BY S.student_id, S.nazwisko, S.imie

SELECT S.student_id, S.nazwisko, S.imie, COUNT(CASE WHEN SUBSTR(wynik, 1, 1)='Z' THEN wynik END) Pozytywne, COUNT(CASE WHEN SUBSTR(wynik, 1, 1)='N' THEN wynik END) Negatywne
FROM studenci S 
	INNER JOIN zaliczenia Z ON Z.student_id=S.student_id
WHERE S.student_id='0500324' AND (Z.wynik='Zaliczony'OR z.wynik ='Negatywny')
GROUP BY S.student_id, S.nazwisko, S.imie

--z17
SELECT K.kierunek_id, Nazwa, Z. kierunek_id, COUNT(*)
FROM kierunki K 
	INNER JOIN zaliczenia Z ON Z.kierunek_id=K.kierunek_id
GROUP BY K.kierunek_id, Nazwa, Z.kierunek_id

-- -> połowicznie dobrze - tylko połowa kierunków (część wspólna)
SELECT K.kierunek_id, Nazwa, Z. kierunek_id, COUNT(*), COUNT(K.kierunek_id), COUNT(Z.kierunek_id)
FROM kierunki K 
	LEFT JOIN zaliczenia Z ON Z.kierunek_id=K.kierunek_id
GROUP BY K.kierunek_id, Nazwa, Z.kierunek_id
-- -> poprawna odpowiedź - left join i poprawny count - zobacz działanie

--z18
SELECT P.przedmiot_id, nazwa, COUNT(*), COUNT(student_id) podejscia, COUNT(DISTINCT student_id) studenci
FROM przedmioty P
	LEFT JOIN zaliczenia Z ON P.przedmiot_id=Z.przedmiot_id
GROUP BY P.przedmiot_id, nazwa
-- count ma różne sposoby zliczania
-- do zadania potrzeba ilość zaliczeń (podejścia do zaliczenia) i liczbę studentów, którzy zaliczali

-- poprawione
SELECT P.przedmiot_id, nazwa, COUNT(*), COUNT(student_id) podejscia, COUNT(DISTINCT student_id) studenci
FROM przedmioty P
	LEFT JOIN zaliczenia Z ON P.przedmiot_id=Z.przedmiot_id
-- WHERE
GROUP BY P.przedmiot_id, nazwa
HAVING COUNT(*)!=COUNT(DISTINCT student_id)
--having to kolejne narzędzie do filtrowania