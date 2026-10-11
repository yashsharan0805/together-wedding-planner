# Architecture and supported features

Together is a static, buildless JavaScript UI plus an adapted LibreWeddingPlanner Rails backend. Nginx serves the UI and proxies the supported API under `/api` on the same origin. Cookies, CSRF and Google popup verification therefore use one browser origin. Production configuration restricts the upstream API to the supported Together routes.

| Component | Local Compose | Hosted container |
| --- | --- | --- |
| UI | `dist/` mounted into Nginx | `dist/` copied into the image |
| API | Rails development container | Rails production/Puma behind Nginx |
| Records/files | Postgres named volume | External Postgres, such as Neon |
| Redis-compatible service | Valkey for upstream local features | Not needed by the hosted planner |
| Invitations | Upstream development mail/Letter Opener | Exact verified Google email plus a manually shared link |

## Records and access

Weddings are identified by a slug. Confirmed membership, not possession of the URL, grants access. `ActsAsTenant` scopes records to the authenticated wedding. Settings, tasks, vendors and budget records use record versions to reject conflicting changes. The UI polls shared state every 12 seconds while visible; it does not use WebSockets.

The Google adapter verifies signature, audience, issuer, expiry, verified email and a session nonce, then binds to Google's stable subject. Every installation needs its own client ID and authorized origins. Hosted identity linking supports Gmail and verified Workspace email. Hosted collaborators must have an invitation for the exact account, accepted before it expires after one week.

Multiple events have their own attendance records. These are planner-maintained RSVPs; a public guest RSVP portal is not exposed by the hosted variant. All accepted collaborators have full view/edit access.

## Documents

`PlannerDocument` belongs to exactly one task or vendor and to the wedding. Metadata appears in planner snapshots; binary file data is fetched only for an authorized download. Mutations lock the wedding and parent to serialize quota checks and check the parent version. Foreign keys/associations remove files when the parent is deleted.

Limits are 3 MiB per file, 10 files per parent and 100 MiB per wedding. PDF, DOCX/XLSX/PPTX, UTF-8 TXT/CSV, PNG/JPEG/WebP are supported. The server validates size and type; Office archive entries are inspected without extraction. Downloads force attachment disposition, octet-stream, `nosniff` and `private, no-store`. Storage is database `bytea`, so it survives container replacement. There is no inline viewer or malware scanner.

## Data lifecycle

Production container startup does not migrate or seed. Migrate explicitly before releases. Back up the database before risky changes; files are part of that database backup. Local `docker compose down` preserves named volumes, while `down -v` deletes them. Never use upstream destructive seeds/reset commands with real wedding data.

The corresponding-source archive and public Git export contain source/configuration templates only. They never need runtime records, uploaded documents, authentication tokens or deployment credentials.
