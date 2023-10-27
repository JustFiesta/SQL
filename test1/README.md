# Notatki do Kolokwium nr 1

1. Używaj aliasów przy JOINACH:

> FROM zaliczenia ZAL \
>> INNER JOIN przedmioty PRZ ON PRZ.przedmiot_id=ZAL.przedmiot_id \
>> INNER JOIN studenci ST ON ST.student_id=ZAL.student_id

2. AND zamiast WHERE:

> AND S.Student_id =  '0000049'

3. Zmiana tekstu wyświetlania:  

> SELECT TO_CHAR(data_zal, 'YYYY/Month/DD') Data2

4. Ogranicz wyświetlanie do unikatów: DISTINCT \

5. Rozbijaj na podzbiory: \

> SELECT Student_id, nazwisko, imie  
> FROM Studenci  
> WHERE student_id NOT IN (
>> SELECT DISTINCT Student_id  
>> FROM Zaliczenia  
>> WHERE przedmiot_id = 7  \
> )  

6. Przypomnij jak działa UNION:  

> SELECT data_zal  
> FROM zaliczenia  
> WHERE data_zal IN (  
>> SELECT MIN(data_zal) FROM zaliczenia  
>> UNION  
>> SELECT MAX(data_zal) FROM zaliczenia  s  
>)
