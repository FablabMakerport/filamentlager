# Filamentlager

Bestand, Verbrauch, Drucke, Projekte und Kalkulator für PLA und PETG.
Live unter **https://filamentlager.makerport.de**, nur für eingeladene Nutzer.

## Aufbau

| Teil | Wo | Aufgabe |
|---|---|---|
| Webseite | GitHub Pages aus dem Ordner `docs/` | liefert das Tool aus, kein FTP nötig |
| Adresse | DNS bei All-Inkl | `filamentlager` zeigt per CNAME auf GitHub Pages |
| Daten, Login, Dateien | Supabase, Region Frankfurt | Datenbank, Anmeldung, Fotos und Druckdateien |

```
docs/                 Alles, was GitHub Pages ausliefert
  index.html          Das Tool
  config.js           Supabase-Adresse + Publishable key (öffentlich, durch RLS geschützt)
  CNAME               Eigene Adresse für GitHub Pages
  .nojekyll           GitHub soll die Dateien unverändert ausliefern
  impressum.html      Vorlage, ausfüllen
  datenschutz.html    Vorlage, ausfüllen
  fonts/, vendor/     Schriften und Bibliotheken lokal (kein Google, kein CDN)
supabase/schema.sql   Datenbank, Zugriffsregeln, Dateispeicher (einmal im SQL Editor ausführen)
```

## Änderungen veröffentlichen

Datei im Ordner `docs/` auf GitHub bearbeiten oder neu hochladen und „Commit changes“ klicken.
Nach ein bis zwei Minuten ist die Änderung live.

## Nutzer verwalten

Supabase → Authentication → Users:
- **Add user → Create new user**: E-Mail und Startpasswort eintragen, „Auto Confirm User“ anhaken. Das Passwort persönlich weitergeben.
- Jeder kann sein Passwort im Tool oben unter **Passwort ändern** selbst ändern.
- **Passwort vergessen**: Nutzer löschen und mit neuem Startpasswort neu anlegen. Die Buchungen bleiben erhalten.
- **Delete user**: Zugang entfernen.

Es werden keine Mails verschickt.

Die Registrierung ist abgeschaltet, ohne Einladung kommt niemand hinein.

## Sicherung

Im Tool unter Bestand → **Excel herunterladen** regelmäßig eine Sicherung ziehen.

## Wichtig

- Das Repository darf öffentlich sein: Es enthält keine Passwörter und keine Daten. Der Publishable key ist für Browser gedacht.
- In `config.js` gehört nur der **Publishable key**. Den Secret key oder service_role key niemals eintragen oder hochladen.
- Wird die Supabase-Adresse geändert, auch die Content-Security-Policy (`connect-src`) im Kopf von `index.html`, `impressum.html` und `datenschutz.html` anpassen.
