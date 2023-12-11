# lab1 - Czym jest encja? Czyli jak modelować bazę danych
Jest to obiekt/wycinek rzeczywistego świata - ożywiony lub nie.

Można go traktować jako obiekt bazy danych, tak jak encja klasy w OOP jest obiektem ożywionym

### Jak oodbywa się projektowanie bytów?
np. słuchanie muzyki - co je defninuje? jakie ma cechy?

Byty służące do słuchania muzyki:
-> urządzenia: pojemność (MB), czas pracy, nazwa, tryb_słuchania
-> utwory: (relacja do albumów ^ - wiele do wielu), (relacja do wykonawcy ^ - wiele do wielu)
-> wykonawcy: nazwa, (relacja do utworów ^),  (relacja do albumów ^ - wiele do wielu)
-> album: rok wydania, (relacja do utworów ^ - wiele do wielu), 
-> grupa: (relacja do wykonawcy ^ - wiele do wielu), (relacja do albumu ^ - wiele do wielu)

itd...

Byty mają swoje cechy -> przybierają kształt pól w tabeli

! Każda relacja wiele do wielu powinna zostać rozpięta - pozwoli to uniknąć niejednoznaczności
#### Jak to zrobić?
Potrzeba tabeli "środkowej" - np. Wykonawcy >-< Grupy
1. Tworzysz tabelę Lista_wykonawców_grup
2. Wykonawcy -< lista_wykonawców_grup >- Grupy

### Normalizacja bazy danych



<hr>

