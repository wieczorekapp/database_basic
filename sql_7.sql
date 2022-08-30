1. !
SELECT id_zesp, nazwa, adres
FROM zespoly
WHERE id_zesp NOT IN (SELECT id_zesp
FROM pracownicy
GROUP BY id_zesp);

SELECT id_zesp, nazwa, adres
FROM zespoly z
WHERE NOT EXISTS (SELECT id_zesp
FROM pracownicy
WHERE id_zesp = z.id_zesp);


2.
SELECT nazwisko, placa_pod, etat
FROM pracownicy p
WHERE placa_pod > (SELECT AVG(placa_pod)
FROM pracownicy
WHERE etat = p.etat
GROUP BY etat 
)
ORDER BY placa_pod DESC;


3.
SELECT nazwisko, placa_pod
FROM pracownicy p
WHERE placa_pod >= (SELECT ROUND(0.75*placa_pod)
FROM pracownicy
WHERE id_prac = p.id_szefa)
ORDER BY nazwisko;


4.
SELECT nazwisko
FROM pracownicy p
WHERE etat = 'PROFESOR' AND NOT EXISTS(SELECT id_prac
FROM pracownicy
WHERE id_szefa = p.id_prac AND etat = 'STAZYSTA')


5.
SELECT z.nazwa, m.maks
FROM (SELECT MAX(SUM(placa_pod)) AS maks
FROM pracownicy
GROUP BY id_zesp) m JOIN (SELECT id_zesp, SUM(placa_pod) AS suma
FROM pracownicy
GROUP BY id_zesp) p ON p.suma = m.maks JOIN zespoly z 
ON p.id_zesp = z.id_zesp;


6.
SELECT nazwisko, placa_pod
FROM pracownicy p
WHERE (SELECT COUNT(*) FROM pracownicy WHERE placa_pod > p.placa_pod) < 3
ORDER BY placa_pod DESC;


7.
SELECT rok, COUNT(*) AS liczba
FROM (SELECT EXTRACT(YEAR FROM zatrudniony) rok FROM pracownicy) 
GROUP BY rok
ORDER BY liczba DESC;


8.
SELECT rok, COUNT(*) AS liczba
FROM (SELECT EXTRACT(YEAR FROM zatrudniony) rok FROM pracownicy) 
GROUP BY rok
ORDER BY liczba DESC
FETCH FIRST 1 ROWS ONLY;


9.
SELECT nazwisko, placa_pod, 
	(placa_pod - (SELECT AVG(placa_pod)
	FROM pracownicy p2
    	WHERE p1.id_zesp = p2.id_zesp
	GROUP BY id_zesp)) AS roznica
FROM pracownicy p1
ORDER BY nazwisko;

SELECT p1.nazwisko, p1.placa_pod, (p1.placa_pod - p2.srednia) AS roznica
FROM (SELECT nazwisko, placa_pod, id_zesp
FROM pracownicy) p1 JOIN (SELECT id_zesp, AVG(placa_pod) AS srednia
FROM pracownicy
GROUP BY id_zesp) p2 
ON p1.id_zesp = p2.id_zesp
ORDER BY p1.nazwisko;


10.
SELECT nazwisko, placa_pod, 
	(placa_pod - (SELECT AVG(placa_pod)
	FROM pracownicy p2
    	WHERE p1.id_zesp = p2.id_zesp
	GROUP BY id_zesp)) AS roznica
FROM pracownicy p1
WHERE (placa_pod - (SELECT AVG(placa_pod)
	FROM pracownicy p2
    	WHERE p1.id_zesp = p2.id_zesp
	GROUP BY id_zesp)) > 0
ORDER BY nazwisko;

SELECT p1.nazwisko, p1.placa_pod, (p1.placa_pod - p2.srednia) AS roznica
FROM (SELECT nazwisko, placa_pod, id_zesp
FROM pracownicy) p1 JOIN (SELECT id_zesp, AVG(placa_pod) AS srednia
FROM pracownicy
GROUP BY id_zesp) p2 
ON p1.id_zesp = p2.id_zesp
WHERE (p1.placa_pod - p2.srednia) > 0
ORDER BY p1.nazwisko;


11.
SELECT prof.nazwisko, COUNT(*) AS podwladni
FROM (SELECT p.id_prac, p.nazwisko
FROM pracownicy p JOIN zespoly z
ON p.id_zesp = z.id_zesp
WHERE p.etat = 'PROFESOR' AND z.adres LIKE '%PIOTROWO%') prof JOIN pracownicy p
ON p.id_szefa = prof.id_prac
GROUP BY prof.nazwisko;


12.
SELECT q.nazwa, q.srednia_w_zespole,
ROUND((SELECT AVG(placa_pod)
FROM pracownicy),2) AS srednia_ogolna,
(CASE
  	WHEN q.srednia_w_zespole IS NULL THEN '???'
	WHEN q.srednia_w_zespole >= ROUND((SELECT AVG(placa_pod) FROM pracownicy),2) THEN ':)'
    WHEN q.srednia_w_zespole < ROUND((SELECT AVG(placa_pod) FROM pracownicy),2) THEN ':('
END) AS nastroje
FROM (SELECT z.nazwa, AVG(p.placa_pod) AS srednia_w_zespole
FROM pracownicy p RIGHT JOIN zespoly z
ON p.id_zesp = z.id_zesp
GROUP BY z.nazwa) q
ORDER BY q.nazwa;


13.
SELECT nazwa,
      (SELECT MIN(placa_pod)
      FROM etaty e1 JOIN pracownicy p1
      ON p1.etat = e1.nazwa
      WHERE e1.nazwa = e.nazwa) AS placa_min,
      (SELECT MAX(placa_pod)
      FROM etaty e1 JOIN pracownicy p1
      ON p1.etat = e1.nazwa
      WHERE e1.nazwa = e.nazwa) AS placa_max
FROM etaty e
ORDER BY (SELECT COUNT(*)
FROM pracownicy p1
WHERE p1.etat = e.nazwa
) DESC, e.nazwa;
 
