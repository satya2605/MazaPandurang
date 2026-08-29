# Tilak AI Technical API Contract & Safety Specification

## Overview
Tilak AI is a context-aware, safety-grounded AI assistant for the Maza Pandurang application.
It provides Varkari pilgrims with answers grounded in live Supabase database records while enforcing strict safety disclaimers for emergencies.

---

## REST API Endpoint

### `POST /api/ai/tilak/chat`
**Authentication:** Required (`Authorization: Bearer <token>` or `x-user-id` in dev/test environment).

#### Request Body Schema
```json
{
  "message": "Where is the Palkhi currently?",
  "context": {
    "latitude": 18.3411,
    "longitude": 74.0305
  }
}
```

#### Response Body Schema (Success `200 OK`)
```json
{
  "success": true,
  "reply": "🚩 The Sant Dnyaneshwar Maharaj Palkhi is currently at Saswad Stay (सासवड मुक्काम). Next upcoming stop is Jejuri (जेजुरी).",
  "intent": "palkhi_location",
  "actions": [
    {
      "type": "palkhi",
      "id": "PALKHI-DEMO-001",
      "label": "📍 Track Palkhi on Map",
      "targetRoute": "/palkhi"
    }
  ],
  "sources": [
    "palkhi_tracking"
  ]
}
```

#### Response Body Schema (Emergency Safety `200 OK`)
```json
{
  "success": true,
  "reply": "🚩 Emergency Alert! Please stay calm. If you or someone around you requires immediate medical, police, or rescue assistance, tap the 'Send SOS' button below immediately.",
  "intent": "emergency",
  "actions": [
    {
      "type": "emergency",
      "label": "🚨 Send Emergency SOS",
      "targetRoute": "/help"
    },
    {
      "type": "service",
      "label": "🏥 Find Medical Help",
      "targetRoute": "/services"
    }
  ],
  "sources": [
    "emergency_dispatch_system"
  ]
}
```

---

## Safety & Privacy Rules

1. **Mandatory JWT Authentication:** `POST /api/ai/tilak/chat` requires valid user authentication via `authenticateJwt`.
2. **Grounding Guardrail:** Live database tables (`palkhi_tracking`, `wari_route`, `services`, `dindis`, `lost_person_reports`) are fetched server-side. AI models MUST NOT fabricate database records.
3. **Privacy Boundary:** Never expose private storage URLs, credentials, registration documents, or unapproved lost person cases to the AI prompt.
4. **Emergency Disclaimers:** For medical or SOS queries, the AI MUST NOT claim to be a first responder authority; it MUST present the `Send SOS` action card.
