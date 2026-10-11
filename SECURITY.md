# Security and private configuration

Report vulnerabilities through the repository's **Security → Report a vulnerability** when private reporting is enabled. Do not put credentials, wedding records, documents, screenshots or exploit data in a public issue. Until the maintainer configures a private reporting channel, request one without posting details. No paid support or response-time guarantee is offered.

## What belongs in Git

| Value or file | Handling |
| --- | --- |
| `DATABASE_URL`, direct migration URL | Secret; local ignored file or deployment environment only |
| `SECRET_KEY_BASE` | Secret; generate for your own installation, keep stable between releases |
| Neon/Vercel/GitHub CLI tokens | Secret; provider CLI credential store, never source or build context |
| Google OAuth **client ID** | Public browser configuration; use your own client and authorized origins |
| Google client secret/password | This app's popup flow does not need either; never add them |
| Database records and task/vendor files | Private runtime data; never export with source |
| TLS inspection certificates | Machine/organization configuration; excluded from exports and image build context |
| `.env*.example` | Empty fields and safe examples only |

Production settings belong in the host's protected environment settings. Local copies must be ignored, permission `600`, and outside distributable source. Gitignore does not remove a file already committed. Preview deployments must use a separate database and secret; do not connect public pull requests to production credentials.

The only hardcoded database password is for the isolated, loopback-bound local Compose/test database. Never use it in production. Never expose the local database to the internet.

## Checks before publication

```sh
python3 scripts/package-source.py
python3 scripts/check-public-source.py
python3 scripts/prepare-public-repo.py
```

The export fails rather than overwriting an existing directory. It copies an explicit source inventory, omits nested Git history, encrypted credentials, runtime files and provider account links, includes the adapted backend, and rebuilds its source archive. It checks actual private values found in local environment files plus a small set of credential patterns. These are safeguards, not proof that every possible unknown secret has been detected.

Run the broader Gitleaks scanner too. The included CI scans files, archives and all fetched Git history using a pinned official image, without production secrets. Locally, use the same image/commands from `.github/workflows/security.yml`, against the clean export. Keep reports redacted. Do not create broad scanner allowlists to make a failing check green; fix the source or document a narrowly reviewed false positive.

Enable GitHub secret scanning, push protection and private vulnerability reporting for the published repository. Keep protection enabled and investigate alerts. GitHub's supported-pattern scanning does not cover every arbitrary database password or session secret. [GitHub scanning scope](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope).

## If a secret was exposed

1. Revoke or rotate it at the provider immediately. Rotate a leaked database password and update host configuration; rotating `SECRET_KEY_BASE` invalidates existing sessions.
2. Identify all copies: Git history, PRs, logs, Actions artifacts, image layers, source archives and hosted downloads.
3. Remove it from source and historical copies using a coordinated cleanup. Redeploy a clean image/archive. Removing the latest file alone leaves old commits and downloaded copies available.
4. Re-run scans, verify the replacement works, and review provider access logs where available.

Do not rotate credentials merely because a scanner found a documented local-development placeholder. The release audit found no production DB/session values in the inspected source/history/archive; it did identify personal account information in old documentation, which was generalized. Previously downloaded copies cannot be recalled. [GitHub sensitive-data cleanup](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

## Current product boundaries

Every accepted wedding member can view, edit and download the wedding's records/files. Invitations do not create viewer-only access. Task/vendor downloads require membership; upload/removal require session authentication and CSRF. Files are stored in Postgres and count toward database/storage quotas. There is no malware scanner, antivirus guarantee or automatic backup/restore UI. Downloaded files remain under the recipient's control. Removing a parent task/vendor removes its attachments.

Before hosting for people beyond your own wedding, establish a privacy policy, backup/retention/deletion process, dependency update process and private incident channel appropriate to your deployment. Source licensing does not grant anyone access to wedding data.
