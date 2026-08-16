# Founder Sim - GitHub Actions und Pages

## Ziel
Jeder Push auf `main` fuehrt zuerst automatische Pruefungen aus. Nur wenn diese erfolgreich sind, wird `app/web/` als GitHub Pages Site veroeffentlicht.

Workflow:
`.github/workflows/founder-sim.yml`

## Einmalige GitHub-Einstellung
1. Repository `Wasserwolke/founder-sim` oeffnen.
2. `Settings` -> `Pages`.
3. Unter `Build and deployment` bei `Source` **GitHub Actions** auswaehlen.
4. Danach unter `Actions` den Workflow `Founder Sim - Test and Deploy` beobachten.

## Automatische Pruefungen
- Python-Skripte kompilierbar
- JSON-Dateien gueltig
- JavaScript-Syntax gueltig
- Asset-/Catalog-Verknuepfungen gueltig
- lokaler HTTP-Smoke-Test fuer `index.html`, Asset Manifest und deutsche Locale

## Deployment
Der Deploy-Job laeuft nur fuer `main` und erst nach erfolgreicher Validierung.
Das GitHub-Pages-Artifact besteht ausschliesslich aus `app/web/`.

## Manuell erneut ausfuehren
`Actions` -> `Founder Sim - Test and Deploy` -> `Run workflow`.

## Wichtig bei privatem Repository
GitHub Pages fuer private persoenliche Repositories benoetigt einen passenden GitHub-Tarif. Bei einem persoenlichen privaten Repository ist die veroeffentlichte Pages-Site grundsaetzlich oeffentlich erreichbar; private Pages-Sites sind eine Enterprise-Funktion fuer Organisationen.
