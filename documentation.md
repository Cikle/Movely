# Projekt-Dokumentation

Lutziger Cyril

| Datum | Version | Zusammenfassung                                                                                    |
|-------|----------|---------------------------------------------------------------------------------------------------|
| 17.01.25 | 0.0.1   | Authentifizierung implementiert, OTP-System integriert                                           |
| 24.01.25 | 0.0.2   | Streak-System entwickelt, Login-Streak implementiert                                             |
| 31.01.25 | 0.0.3   | Soziale Funktionen integriert, Follower-System implementiert                                     |
| 21.02.25 | 0.0.4   | Integration und Tests durchgeführt, UI/UX optimiert                                              |

## 1 Informieren

### 1.1 Ihr Projekt

Movely ist eine Fitness-Tracking-Anwendung, die Streak-Systeme wie bei Duolingo mit Aktivitätsverfolgung wie bei Adidas Running kombiniert. Die App nutzt ein Instagram-ähnliches Dark Mode UI/UX Design und legt besonderen Wert auf minimale Datennutzung.

### 1.2 User Stories

| US-№ | Verbindlichkeit | Typ | Beschreibung |
|------|----------------|-----|--------------|
| 1.1  | Muss | Funktional | Als User möchte ich mich mit meiner E-Mail registrieren können |
| 1.2  | Muss | Funktional | Als User möchte ich mich mit einem OTP-Code einloggen können |
| 2.1  | Muss | Funktional | Als User möchte ich meine täglichen Schritte tracken können |
| 2.2  | Muss | Funktional | Als User möchte ich meine Schritt-Statistiken sehen können |
| 3.1  | Muss | Funktional | Als User möchte ich einen Login-Streak aufbauen können |
| 3.2  | Muss | Funktional | Als User möchte ich EXP für meine Aktivitäten erhalten |
| 4.1  | Muss | Funktional | Als User möchte ich anderen Nutzern folgen können |
| 4.2  | Muss | Funktional | Als User möchte ich die Aktivitäten anderer sehen können |

### 1.3 Testfälle

| TC-№ | Ausgangslage | Eingabe | Erwartete Ausgabe |
|------|--------------|---------|-------------------|
| 1.1.1 | App geöffnet | E-Mail eingeben und registrieren | Erfolgreich registriert |
| 1.2.1 | E-Mail eingegeben | OTP-Code eingeben | Erfolgreich eingeloggt |
| 2.1.1 | Eingeloggt | App öffnen und bewegen | Schritte werden gezählt |
| 2.2.1 | Schritte getrackt | Statistiken aufrufen | Übersicht wird angezeigt |
| 3.1.1 | Täglich einloggen | - | Streak erhöht sich |
| 3.2.1 | Aktivitäten ausführen | - | EXP wird gutgeschrieben |
| 4.1.1 | Andere User suchen | Follow klicken | Erfolgreich gefolgt |
| 4.2.1 | Eingeloggt | Aktivitäten-Feed öffnen | Feed wird angezeigt |

### 1.4 Diagramme
![Screenshot 2025-03-07 145519](https://github.com/user-attachments/assets/cfad2a50-64f9-44fb-a632-649648eba64e)
Erstellt mit der Hilfe von Phind.

## 2 Planen

| AP-№ | Frist | Zuständig | Beschreibung | geplante Zeit |
|------|-------|-----------|--------------|---------------|
| 1.A  | 17.01.25 | Cyril Lutziger | Implementierung der E-Mail-Registrierung | 120' |
| 1.B  | 17.01.25 | Cyril Lutziger | Integration des OTP-Systems | 90' |
| 2.A  | 24.01.25 | Cyril Lutziger | Implementierung der Schritterkennung | 180' |
| 2.B  | 24.01.25 | Cyril Lutziger | Entwicklung der Anzeige | 120' |
| 3.A  | 31.01.25 | Cyril Lutziger | Entwicklung des Streak-Systems | 150' |
| 3.B  | 31.01.25 | Cyril Lutziger | Implementation des EXP-Systems | 90' |
| 4.A  | 21.02.25 | Cyril Lutziger | Entwicklung der Follower-Funktionalität | 180' |
| 4.B  | 21.02.25 | Cyril Lutziger | Integration des Aktivitäten-Feeds | 150' |

## 3 Entscheiden

Die GPS-Routenverfolgung wurde aus Zeitgründen aus dem Projektumfang entfernt. Der Fokus wurde stattdessen auf die Verbesserung der Kernfunktionen gelegt.

## 4 Realisieren

| AP-№ | Datum | Zuständig | geplante Zeit | tatsächliche Zeit |
|------|-------|-----------|---------------|-------------------|
| 1.A  | 17.01.25 | Cyril Lutziger | 120' | 135' |
| 1.B  | 17.01.25 | Cyril Lutziger | 90' | 100' |
| 2.A  | 24.01.25 | Cyril Lutziger | 180' | 195' |
| 2.B  | 24.01.25 | Cyril Lutziger | 120' | 130' |
| 3.A  | 31.01.25 | Cyril Lutziger | 150' | 165' |
| 3.B  | 31.01.25 | Cyril Lutziger | 90' | 95' |
| 4.A  | 21.02.25 | Cyril Lutziger | 180' | 200' |
| 4.B  | 21.02.25 | Cyril Lutziger | 150' | 170' |

## 5 Kontrollieren

### 5.1 Testprotokoll

| TC-№ | Datum | Tester | Resultat | Bemerkung |
|------|-------|--------|-----------|-----------|
| 1.1.1 | 17.01.25 | Cyril Lutziger | OK | - |
| 1.2.1 | 17.01.25 | Cyril Lutziger | OK | - |
| 2.1.1 | 24.01.25 | Cyril Lutziger | OK | - |
| 2.2.1 | 24.01.25 | Cyril Lutziger | OK | - |
| 3.1.1 | 31.01.25 | Cyril Lutziger | OK | Streak-Reset bei Mitternacht funktioniert |
| 3.2.1 | 31.01.25 | Cyril Lutziger | OK | EXP-System arbeitet korrekt |
| 4.1.1 | 21.02.25 | Cyril Lutziger | OK | Follow-Funktion implementiert |
| 4.2.1 | 21.02.25 | Cyril Lutziger | OK | Feed zeigt Aktivitäten korrekt an |
