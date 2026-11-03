# Filamentlager

Bestand, Verbrauch, Drucke, Projekte und Kalkulator für PLA und PETG.
Live unter **https://filamentlager.makerport.de**, nur für eingeladene Nutzer.

## Aufbau

| Teil | Wo | Aufgabe |
|---|---|---|
| Webseite | All-Inkl, Ordner der Subdomain | liefert die Dateien aus `public/` aus |
| Daten, Login, Dateien | Supabase, Region Frankfurt | Datenbank, Anmeldung, Fotos und Druckdateien |
| Code | dieses private Repository | jede Änderung in `public/` wird automatisch hochgeladen |

```
public/                 Alles, was auf den Webspace kommt
  index.html            Das Tool
  config.js             Supabase-Adresse + Publishable key (öffentlich, durch RLS geschützt)
  impressum.html        Vorlage, ausfüllen
  datenschutz.html      Vorlage, ausfüllen
  .htaccess             https, Sicherheitsregeln, nur Verbindungen zu Supabase erlaubt
  fonts/, vendor/       Schriften und Bibliotheken lokal (kein Google, kein CDN)
supabase/schema.sql     Datenbank, Zugriffsregeln, Dateispeicher (einmal im SQL Editor ausführen)
.github/workflows/deploy.yml   Automatischer Upload per FTPS
```

## Änderungen veröffentlichen

Datei im Repository bearbeiten oder neu hochladen und speichern („Commit changes“).
Unter **Actions** läuft dann „Deploy zu All-Inkl“, nach etwa einer Minute ist die Änderung live.
Manuell starten: Actions → Deploy zu All-Inkl → Run workflow.

## Nutzer verwalten

Supabase → Authentication → Users:
- **Invite user**: neue Person einladen, sie legt ihr Passwort selbst fest.
- **Delete user**: Zugang entfernen.

Die Registrierung ist abgeschaltet, ohne Einladung kommt niemand hinein.

## Sicherung

Im Tool unter Bestand → **Excel herunterladen** regelmäßig eine Sicherung ziehen.
Der kostenlose Supabase-Plan enthält keine herunterladbaren Backups.

## Wichtig

- In `config.js` gehört nur der **Publishable key**. Den Secret key oder service_role key niemals eintragen oder hochladen.
- Wird die Supabase-Adresse geändert, auch die Zeile `connect-src` in `public/.htaccess` anpassen.
- Kostenlose Supabase-Projekte werden nach längerer Inaktivität pausiert und lassen sich im Dashboard wieder starten.
