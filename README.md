# Together — wedding planner

An open-source browser planner adapted from LibreWeddingPlanner, with a responsive interface for Indian weddings and multiple celebrations. Track tasks, guests and per-event attendance, budgets/payments, vendors, and private task/vendor documents. Google sign-in and shared wedding workspaces are supported.

Licensed under **GNU AGPL version 3**. Preserve [LICENSE.md](LICENSE.md), [COPYING.md](COPYING.md), upstream notices and the [source/asset attribution](NOTICE.md). The hosted app offers its corresponding source through the footer.

## Run your own planner

Requirements: Git, Python 3.9+ for source tools, Docker Engine with Compose v2 (Docker Desktop works), a modern browser and internet access to package registries/Google. Node is optional for JavaScript syntax checks; no frontend build is required. Docker supplies Ruby, Rails, Postgres and Valkey. The first image build can take several minutes.

A public export contains the complete adapted `backend/`; no separate upstream clone is needed:

```sh
git clone https://github.com/YOUR_ACCOUNT/YOUR_REPOSITORY.git
cd YOUR_REPOSITORY
cp .env.example .env
```

Create your own Google web client using [the Google guide](docs/google-sign-in.md), authorize `http://localhost:8080`, and fill `GOOGLE_CLIENT_ID` in `.env`. The client ID is public configuration; this flow needs no Google password or client secret.

```sh
docker compose -f compose.yml up --build -d
docker compose -f compose.yml logs --tail=80 backend
```

Open http://localhost:8080. Choose a wedding address, select **Create a new wedding with Google**, and sign in. Set names, date, venue, currency and budget in Settings, then add celebrations in Events. For later sign-ins, leave the creation checkbox unchecked.

The local database is bound through the application on loopback only. Records live in Docker named volumes. Stop with `docker compose -f compose.yml down` to preserve data. **Do not use `down -v`, `rails db:reset`, `rails db:seed`, or upstream seed scripts with real records.** No default account is created. If package downloads fail on a corporate network, use the optional CA procedure in [deployment](docs/deployment.md), keeping TLS verification enabled.

## Share and attach documents

In the hosted variant, use **Invite people**, add a collaborator's exact Gmail/Workspace email, then share the workspace link yourself. They join through verified Google sign-in before the invitation expires after one week; no invitation email is sent. Local Compose retains upstream mail-based invitations and development messages at http://localhost:8080/letter_opener/; confirmation/acceptance may require both emails.

All accepted collaborators can view/edit the wedding and download its files. The link alone grants no access. Updates refresh every 12 seconds; conflicting edits are rejected. There are no viewer-only roles.

On tasks or vendors, select **Documents**, or **Save & attach documents** when editing. Supported formats: PDF, DOCX/XLSX/PPTX, UTF-8 TXT/CSV and PNG/JPEG/WebP. Limits: 3 MiB/file, 10 files/item and 100 MiB/wedding. Files persist in Postgres and remain private to members. Removing a task/vendor removes its documents. There is no malware scanner or inline viewer.

## Deploy

See [deployment](docs/deployment.md) for the production container and Vercel Hobby + Neon option. Use your own provider accounts, database, session secret and Google client. Hosting quotas/beta availability can change. Hobby is intended for personal, noncommercial use. The local Compose stack runs in development and is not the production setup.

Copy `.env.production.example` to a private ignored file only when preparing a deployment. Keep production values in your host's environment settings, never in Git, UI code, CI logs or public issue reports. Preview deployments must not use production credentials. See [SECURITY.md](SECURITY.md).

## Project map

| Path | Purpose |
| --- | --- |
| `dist/` | Buildless UI; default `config.js` is a browser-local demo |
| `backend/` | Adapted Rails API, records, migrations and tests |
| `deploy/` | Same-origin Nginx and live/hosted configuration |
| `compose.yml` | Local Rails/Postgres/Valkey/Nginx stack |
| `Dockerfile.vercel`, `vercel.json` | Production container setup |
| `scripts/package-source.py` | Checked corresponding-source archive |
| `scripts/prepare-public-repo.py` | Fresh public monorepo export without private history |
| `.github/workflows/security.yml` | File/archive/history secret scanning |

This development workspace keeps the original backend as a nested Git checkout. An ordinary push of that workspace would omit the ignored backend. Prepare the clean export described in [open-source publication](docs/open-source.md), then publish that directory with fresh history. Public clones have ordinary backend files and no nested repository.

## Documentation and contribution

- [Architecture and supported features](docs/architecture.md)
- [Google sign-in setup and troubleshooting](docs/google-sign-in.md)
- [Hosting and migrations](docs/deployment.md)
- [GitHub publication, licensing and audit findings](docs/open-source.md)
- [Dependency and asset licensing review](docs/licensing.md)
- [Security and credential handling](SECURITY.md)
- [Contributing and focused tests](CONTRIBUTING.md)
- [Validation and known limits](docs/validation.md)
- [Original planner comparison](docs/options.md)

Upstream source/base commit are recorded in NOTICE. This fork is an independent adaptation. See the contribution guide before proposing changes upstream.
