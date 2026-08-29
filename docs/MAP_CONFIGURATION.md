# Maza Pandurang — Map & Credential Configuration Guide

This document specifies the MapLibre + MapTiler + OpenStreetMap mapping configuration and credential architecture for the developer team.

---

## 🗺 Map Stack Architecture

```text
                     PILGRIM APP
                          │
                          ▼
                 MapLibre Flutter
                          │
                          ▼
            MapTiler (Vector/Raster Tiles)
                          │
                          ▼
                 OpenStreetMap Data
```

- **Renderer**: MapLibre Flutter (`maplibre_gl`)
- **Style & Tiles**: MapTiler (`https://api.maptiler.com/maps/streets-v2/style.json?key=MAPTILER_KEY`)
- **Geographic Data**: OpenStreetMap (OSM)

---

## 🔑 Credential Architecture Rules

1. **Client-side Public Keys (Flutter)**:
   - MapTiler client API key (`MAPTILER_API_KEY`) is client-visible for browser rendering on Flutter Web.
   - **Protection Strategy**: Restrict allowed HTTP Origins/Domains in your [MapTiler Cloud Dashboard](https://cloud.maptiler.com/).
   - **Rule**: NEVER hardcode API keys into source code, Git commits, READMEs, or agent communication files.

2. **Server-side Secrets (Node.js Backend)**:
   - Private tokens (Supabase service role key, AI provider keys, MapTiler service tokens) belong exclusively in `backend/.env`.
   - **Rule**: Never send private server secrets to the Flutter client.

---

## 🚀 Running the App Locally with MapTiler Key

### Option A: Command Line (`flutter run`)
Pass your MapTiler API key using `--dart-define`:

```bash
flutter run -d chrome --dart-define=MAPTILER_API_KEY=YOUR_MAPTILER_API_KEY
```

### Option B: Environment Variable & Batch Scripts
Set the `MAPTILER_API_KEY` environment variable in your terminal session before executing `run.bat` or `run_app.bat`:

```cmd
set MAPTILER_API_KEY=YOUR_MAPTILER_API_KEY
.\run_app.bat
```

*Note: If no API key is provided, the application will display a developer notification banner and fallback to a custom canvas grid while keeping all overlays, route lines, and navigation functional.*
