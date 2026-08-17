# Founder Sim - Entwicklungsregeln

Diese Regeln gelten fuer alle kuenftigen Aenderungen am Projekt.

## 1. Sauberkeit vor Patchwork
- Vor einer Erweiterung pruefen, ob sie in die bestehende Struktur passt.
- Wenn ein Feature nur durch mehrere Sonderfaelle oder parallele Hilfsfunktionen passt, zuerst Refactoring erwaegen.
- Veralteten, duplizierten oder ersetzten Code entfernen statt dauerhaft mitzuschleppen.
- Bugfixes sollen die Ursache beheben, nicht nur Symptome ueberdecken.
- Kleine, klar abgegrenzte Module und stabile Schnittstellen bevorzugen.
- Keine Abstraktion nur um der Abstraktion willen; der Code soll so klein wie sinnvoll bleiben.
- Keine Sammlung aus Einmal-Fix-Skripten fuer einzelne Symptome. Wiederkehrende Wartung gehoert in wenige allgemeine, idempotente Werkzeuge; einmalige Reparaturen werden nach Gebrauch entfernt oder in die eigentliche Codebasis ueberfuehrt.
- Bevor ein neues Hilfsskript entsteht, pruefen, ob ein vorhandenes Werkzeug sinnvoll erweitert oder das Problem direkt im verantwortlichen Modul geloest werden kann.

## 2. Verstaendlicher Code
- Funktionen erhalten eine kurze Docstring-/Kommentar-Erklaerung, wenn Zweck oder Seiteneffekte nicht unmittelbar offensichtlich sind.
- Groessere logische Abschnitte werden knapp kommentiert.
- Kommentare erklaeren WARUM etwas geschieht; der Code selbst soll das WAS moeglichst klar ausdruecken.
- Beim Anfassen alter Funktionen veraltete Kommentare aktualisieren oder entfernen.
- Fachlogik soll dort liegen, wo man sie anhand ihres Namens erwartet. Beispiel: ELSTER-/Steuerlogik gehoert in ein eindeutig benanntes Steuer-/Buerokratie-Modul statt verteilt in UI-, Fix- und Hilfsskripten.
- Ordner und Dateien nach Fachbereich statt nach kurzfristigem Implementierungsgrund benennen. Ziel: Ein neuer Entwickler soll mit wenigen Klicks zur verantwortlichen Logik gelangen.

## 3. Architektur pruefen
Vor groesseren Features kurz entscheiden:
1. Passt das Feature in ein vorhandenes Modul?
2. Braucht es eine neue Schnittstelle statt direkter Abhaengigkeiten?
3. Werden alte Funktionen/Strukturen dadurch ueberfluessig?
4. Ist ein Refactoring jetzt guenstiger als weitere Sonderfaelle spaeter?
5. Macht die Aenderung die Codebasis fuer einen Menschen leichter oder schwerer auffindbar?

## 4. Feature-first bei Assets
Gameplay-/Feature-ID, Daten, Regeln und Uebersetzungskeys werden zuerst definiert. Danach folgen Asset-Anforderungen. Bilder enthalten keine Gameplay-Werte wie Preis oder Effekte.

## 5. Abschluss jeder Aenderung
Nach jedem relevanten Commit werden genannt:
- spielbarer GitHub-Pages-Link,
- Commit-Link,
- jede geaenderte Datei mit `+hinzugefuegt/-geloescht`,
- ein kurzer Satz zum Zweck der Aenderung,
- direkter Link zur Datei-History auf GitHub.

`scripts/change_report.py` erzeugt die technischen Dateistatistiken automatisch. GitHub Actions schreibt denselben Bericht in die Run Summary.

## 6. GitHub-Schreibzugriff im gemeinsamen Workflow
- Fuer `Wasserwolke/founder-sim` wird vorhandener GitHub-Schreibzugriff als normale Projektvoraussetzung behandelt.
- Wenn eine angeforderte Aenderung ins Repository gehoert, zuerst den konkreten Schreibvorgang versuchen statt fehlenden Schreibzugriff anzunehmen.
- Nur wenn der reale GitHub-Schreibvorgang mit einem Berechtigungs-/Verbindungsfehler scheitert, diesen Fehler melden und auf einen alternativen Workflow ausweichen.
- Erfolgreiche Schreibvorgaenge werden anschliessend durch die vorhandene CI validiert; ein CI-Codefehler ist von einem Schreibzugriffsfehler zu unterscheiden.
