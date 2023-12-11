-- notatki do funkcji agregujących / najczęstsze błędy z kolokwium
-- SELECT AVG(LZ), COUNT(*), TO_CHAR(data_zal, 'YYYY')
-- FROM
-- 	(SELECT data_zal, COUNT(*) LZ
-- 	FROM zaliczenia
-- 	GROUP BY data_zal) X
-- GROUP BY TO_CHAR(data_zal, 'YYYY')

-- tabliczka mnożenia do 7 - ilocyzn kartezjański zbiorów (ale nie da się zastosować dokładnego filtrowania)
-- SELECT P1.przedmiot_id * P2.przedmiot_id, P1.przedmiot_id, P2.przedmiot_id 
-- FROM przedmioty P1, przedmioty P2

-- kalkulator? XD
-- SELECT P1.przedmiot_id * P2.przedmiot_id, P1.przedmiot_id, P2.przedmiot_id 
-- FROM przedmioty P1, przedmioty P2
-- WHERE P1.przedmiot_id=7 AND P2.przedmiot_id=7

-- przykład błędnego użycia iloczynu kartezjańskiego - pokazuje przyporządkowanie każdy do każdemu
-- SELECT student_id, wykladowca_id
-- FROM wykladowcy W, studenci S
-- WHERE W.miasto=S.miasto

-- o co tu chodzi?
SELECT S.student_id, nazwisko, imie, TO_CHAR(data_zal, 'YYYY-MM-DD') data_zaliczenia, S.pesel, CASE SUBSTR(pesel,3,1)>1 THEN '20' ELSE '19' END || SUBSTR(pesel, 1, 2) || CASE WHEN SUBSTR(PESEL, 3, 1)>1 THEN -20 ELSE END + (SUBSTR(PESEL, 5, 2), 'YYYYMMDD'))
FROM studenci S, zaliczenia z
WHERE S.student_id=Z.student_id

-- zadania

-- z20
INSERT INTO wykladowcy (wykladowca_id, nazwisko, imie) VALUES (999, 'Fifonż', 'Nowakowski')

SELECT W.wykladowca_id, nazwisko, imie, COUNT(z.wykladowca_id) Liczba_zal
FROM wykladowcy W LEFT JOIN zaliczenia Z ON W.wykladowca_id=Z.wykladowca_id
GROUP BY W.wykladowca_id, nazwisko, imie
HAVING COUNT(z.wykladowca_id)=0
ORDER BY liczba_zal DESC
-- rekord pusty nie istnieje - biorąc COUNT(*) nie pokazuje nam rekordów pustych

-- zoptymalizujmy powyższy kod

-- użycie funkcji grupującej wcześniej - ogranicza konieczność fitracji ponownej (przy having powyżej)
SELECT W.wykladowca_id, nazwisko, imie, Liczba_zal
FROM wykladowcy W INNER JOIN (
	SELECT wykladowca_id, COUNT(*) Liczba_zal
	FROM zaliczenia X
	GROUP BY wykladowca_id
) X ON W.wykladowca_id=X.wykladowca_id
WHERE X.Liczba_zal>10

-- v.2 z obsłużonym null - poprawne zapytanie do raportu 
SELECT W.wykladowca_id, nazwisko, imie, COALESCE(X.Liczba_zal, 0)
FROM wykladowcy W LEFT JOIN (
	SELECT wykladowca_id, COUNT(*) Liczba_zal
	FROM zaliczenia X
	GROUP BY wykladowca_id
) X ON W.wykladowca_id=X.wykladowca_id
WHERE COALESCE(X.Liczba_zal, 0)=0

-- krotka z technicznym zapytaniem bazy (ctid)
-- SELECT ctid, W.*
-- FROM wykladowcy W

-- z21
SELECT Z.kierunek_id, nazwa, COUNT(*), COUNT(student_id)
FROM zaliczenia Z RIGHT JOIN kierunki K ON K.kierunek_id=Z.kierunek_id
GROUP BY Z.kierunek_id, nazwa
HAVING COUNT(student_id)>7

-- z22
-- distinct bo ktoś mógł poprawić przedmiot - my pytamy się ilu STUDENTÓW zaliczało przedmiot, nie ważne ile podchodził
SELECT P.przedmiot_id, nazwa, COUNT(*), COUNT(student_id), COUNT(DISTINCT student_id)
FROM przedmioty P LEFT JOIN zaliczenia Z ON Z.przedmiot_id=P.przedmiot_id
GROUP BY P.przedmiot_id, nazwa
HAVING COUNT(DISTINCT student_id)>5

-- z23
SELECT S.student_id, imie, nazwisko, COUNT(*), COUNT(kierunek_id), COUNT(DISTINCT kierunek_id)
FROM studenci S LEFT JOIN zaliczenia Z ON S.student_id=Z.student_id
GROUP BY S.Student_id, imie, nazwisko

-- z24
-- 1. SELECT, FROM, JOIN itd
SELECT S.student_id, imie, nazwisko, COALESCE(SUM(P.ects), 0) -- 4. COALESCE - zastąp null 0 
FROM studenci S LEFT JOIN zaliczenia Z ON S.student_id=Z.student_id AND wynik LIKE 'Z%' -- 3.wzięło teraz wszystkich studentów, którzy zaliczali
	LEFT JOIN przedmioty P ON P.przedmiot_id=Z.przedmiot_id
	-- powyzszy left join mozna zmienic na inner - do wyniku pelnego odrzuce pryzpadki nie spełniające LIKE ^
-- bez where liczy tych co nie zdali jako 100, a tych co nie podchodzili jako null (możemyu dodać IS NULL)
-- 2. WHERE COALESCE(wynik, 'Zal') LIKE 'N%'
GROUP BY S.Student_id, imie, nazwisko

-- z25
-- SELECT S.student_id, imie, nazwisko, 
