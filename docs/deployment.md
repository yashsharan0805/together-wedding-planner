# Hosting the live planner

Together can run on Vercel Hobby (container runtime, beta) plus Neon Free Postgres, or on another host capable of running the production container. Create your own provider accounts and credentials. The production schema is migrated explicitly before releases.

The supplied Compose stack binds port 8080 to `127.0.0.1` and runs Rails in development. Production uses the separate container configuration below. Keep the AGPL notices and corresponding modified source available through the Source link. Rebuild `dist/together-source.tar.gz` after source changes. If enabling upstream email-based invitations later, configure transactional email and test delivery separately.

## Local builds on a corporate network

If RubyGems reports an untrusted corporate TLS certificate, use the organization's CA already trusted by your Mac. Do not disable certificate verification. If your organization uses TLS inspection, export its already trusted CA into a Git-ignored local folder (replace the certificate name below):

```sh
mkdir -p backend/.local-certs
security find-certificate -a -c YOUR_CORPORATE_CA -p /Library/Keychains/System.keychain > backend/.local-certs/corporate-ca.crt
docker compose -f compose.yml -f compose.corporate.yml build backend
```

The optional overlay supplies that certificate as a BuildKit secret. The local image installs it in its trust store before fetching gems over HTTPS. Certificate files are excluded from the source archive. Use the standard `compose.yml` without the overlay on networks that do not require this CA. Subsequent local startup uses `docker compose -f compose.yml up -d`.

## Vercel Hobby + Neon

`Dockerfile.vercel` runs the Together UI and Rails behind a single Nginx origin. `vercel.json` explicitly declares the container service and catch-all route, because automatic Dockerfile detection skipped the container in the initial build. Vercel does not run the local Compose stack. Postgres lives in Neon. The project setting `PORT=8080` selects the external HTTP port, while Rails listens privately on port 3000. Container startup never runs database migrations or seeds.

The hosted variant uses Google sign-in and Google invitations. Add a person's Gmail or Google Workspace email under Invite people, then give them the workspace link yourself. A matching, verified Google identity accepts a valid pending membership; the URL alone grants no access. Invitations expire after one week. All accepted members can view and edit the entire wedding. No email is sent. Password recovery, public RSVP pages, upstream artwork uploads, generated seating PDFs, and seating simulation are outside the hosted API. The supported planner needs no Redis service or background worker, and new hosted weddings do not create local invitation-artwork files.

### Deployment steps

For a new installation, create `.env.production.local` from the blank template with file permissions `600`. Generate the session secret once without printing it:

```sh
umask 077
cp .env.production.example .env.production.local
python3 - <<'PY'
from pathlib import Path
import secrets
p = Path('.env.production.local')
p.write_text(p.read_text().replace('SECRET_KEY_BASE=\n', 'SECRET_KEY_BASE=' + secrets.token_hex(64) + '\n'))
p.chmod(0o600)
PY
```

Fill the other fields locally: the pooled Postgres URL, your public Google client ID, the stable hostname without scheme/path, and port 8080. Preserve the session secret on subsequent releases. Never paste the filled file into issues or commit it. Create a separate ignored `.env.migration.local` copy using the direct database URL; the remaining configuration stays the same.

```sh
docker build -f Dockerfile.vercel -t together-hosted .
# New/existing target database must be inspected before migrating.
docker run --rm --env-file .env.migration.local together-hosted bundle exec bin/rails db:migrate
```

For an existing database, take a backup and inspect migration status (`bin/rails db:migrate:status`) before applying changes. A new empty database needs no seed data. Add the production values to the host's production environment settings before deploying; keep previews separate. Production Google login requires HTTPS. A local production-container check can inspect `/up`, but HTTP alone is not a valid secure-cookie login test.

1. Use the Vercel **Hobby** team and Neon **Free** plan. Keep the free generated HTTPS hostname; a purchased domain is optional. Create the production Postgres database and choose a Vercel compute region near it.
2. Generate a stable `SECRET_KEY_BASE` and keep it across deployments. Save production settings only in a Git-ignored, permission-600 environment file and Vercel's secret environment settings. Required settings: `DATABASE_URL` (Neon pooled URL with `sslmode=verify-full` and `sslrootcert=/etc/ssl/certs/ca-certificates.crt`), `SECRET_KEY_BASE`, `GOOGLE_CLIENT_ID`, `APPLICATION_HOST` (stable hostname, without scheme/path), and `PORT=8080`. Do not give preview deployments the production database or secrets.
3. Create/migrate the new database once from an authorized local container using the **direct/unpooled** Neon URL. Inspect an existing database before migrating it. Never run `db:prepare`, `db:seed`, or `db:reset`; upstream seeds destroy records. Use `bin/rails db:migrate`, not migrations during function startup.
4. Run `python3 scripts/stage-vercel.py --isolated`. It prints a temporary deployment folder outside the Git checkout, excludes credentials, local certificates, Git directories and runtime files, and includes the adapted backend from the local source inventory. An existing `.vercel/project.json` identity is copied locally; account tokens are never copied. Deploy with `vercel --cwd <printed-folder> deploy --prod --scope YOUR_TEAM --yes`. Check the displayed project name before continuing: it must be your intended project.
5. Deploy that folder to the Hobby project. Add the exact stable HTTPS origin to Google Auth Platform's existing web client; no client secret or redirect URI is needed for this GIS popup flow.
6. Check `/up`, static UI, a fresh Google challenge, actual Google sign-in, session persistence, two-account sharing and wedding isolation. Do not claim a static preview or mocked verifier proves the deployed login works.

Official references (checked 11 October 2026): [Vercel container runtime](https://vercel.com/docs/functions/runtimes/container), [Hobby limits](https://vercel.com/docs/plans/hobby), [Neon free storage](https://neon.com/blog/neon-free-plan-1-gb-per-project). Free quotas and beta availability can change. Hobby is for personal, noncommercial use. Keep the AGPL corresponding-source link available on the deployed UI.

## Private task and vendor documents

Tasks and vendor details offer **Documents** and **Save & attach documents**. Files are stored as private Postgres `bytea` records in Neon, not in the container filesystem. Existing wedding membership and CSRF protections apply to upload/removal; download requires an authenticated member on every request. URLs grant no access by themselves. Downloads use attachment disposition, `application/octet-stream`, `nosniff`, and `private, no-store`.

Limits: 3 MiB per file, 10 files per task or vendor, and 100 MiB across a wedding. Supported types: PDF, DOCX, XLSX, PPTX, UTF-8 TXT/CSV, PNG, JPEG and WebP. The server checks format and size. Office archive entries are inspected without extraction. Wedding and parent-row locks serialize quota checks and reject stale versions. Removing a task or vendor removes its documents. There is no malware scanning or inline document execution.

This uses the existing free database and requires no new storage account or credential. The limits are app safeguards, not a provider storage guarantee. Database indexes, history and other wedding data also consume the account's quota. Larger media or substantially more documents should use private object storage rather than raising these limits. Nginx accepts 4 MiB multipart requests; the app enforces 3 MiB file payloads, below [Vercel's function payload limit](https://vercel.com/docs/errors/function_payload_too_large). [Neon's Free storage announcement](https://neon.com/blog/neon-free-plan-1-gb-per-project) reports 1 GB per project.
