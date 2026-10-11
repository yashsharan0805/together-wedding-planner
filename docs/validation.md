# Validation and known limits

Last reviewed: 11 October 2026. This document deliberately omits personal accounts, provider identifiers and machine-specific paths.

## Confirmed behavior

- The local Compose stack builds and serves the UI with Rails/Postgres/Valkey; migrations run without upstream destructive seeds.
- Browser demo checks covered task create/complete/persistence, guest creation, independent event attendance, search/filter and desktop/mobile layouts. A 390×844 mobile viewport had no horizontal overflow.
- **29 examples, 0 failures** in the two focused authentication/planner request files. They cover membership and tenant isolation, stale edits, invitation acceptance, Google token/nonce rejection, event attendance, task/vendor attachments, cleanup, quotas, invalid/disguised files and CSRF rejection. Google token verification is mocked in those specs.
- A real Google production login created a shared wedding and persisted after reload. Sharing with two real Google accounts remains unverified.
- The production container boots and serves health/UI/API endpoints. A boot check caught a development-only ZIP dependency; `rubyzip` is now explicit in production. Image-build success alone was insufficient.
- The attachment release serves updated controls and rejects anonymous document access with JSON 401. Arc displayed vendor Documents buttons and the document panel. A browser file upload remains unverified because native file-picker automation could not enable Open; request-level upload/download/removal tests pass.

## Publication audit

The local audit checked six actual production DB/session values against 1,981 current/history/archive blobs: zero matches. The existing publicly served archive was independently fetched and checked, also with no production-secret matches. No plaintext environment files, master keys, Git metadata or runtime output were included. This is bounded evidence, not a guarantee against every unknown secret.

Old docs contained a personal account email and deployment identifiers. They were generalized. The reviewed export excludes encrypted Rails credentials, old nested history, local certificates, runtime files and provider account links. Commented upstream sample keys and a badge URL token were removed. Preserve original legal font notices.

The optional public export uses fresh Git history. Existing local histories are preserved; old archives in them must not be pushed accidentally. The cleaned source archive was redeployed and fetched independently: HTTP 200, no known production-secret matches, personal deployment markers removed, and local owner metadata scrubbed. The health endpoint returns 200. Previously downloaded copies cannot be recalled.

The cleaned export and its archive pass Gitleaks with zero findings. Root history also passes its Git scan; upstream backend history flags the two already-public sample/badge values removed from the export. Five synthetic publication guard tests pass. A synthetic fresh commit/clone confirms all 462 backend files are tracked as ordinary files, source tooling works in a flat clone, and the fresh history passes Gitleaks. Archive owner metadata is scrubbed, executable modes are preserved, and the complete backend is included without a gitlink.

## Remaining release checks

- Complete real two-account collaboration and live browser attachment upload/download verification.
- Ruby gem metadata and targeted notices were reviewed for 184 resolved gems (138 default-group dependencies). No obvious mandatory incompatible license was found; Sidekiq is LGPLv3. Container/native package obligations and the individual provenance of the retained upstream sample photo still need a complete release review. See [licensing review](licensing.md).
- Configure a private vulnerability-reporting channel, GitHub push protection and repository governance after creating the repository.

## Product limits

All members have full wedding access; there are no viewer-only roles. Collaboration uses polling. The hosted API omits public guest RSVP, upstream artwork upload, seating simulation/PDF generation, password recovery and email delivery. The lightweight image does not install upstream `wkhtmltopdf`. Local Compose runs in development. File downloads require membership, but downloaded copies cannot be revoked and there is no malware scanner. Operators supply their own backups, retention/privacy policy and provider accounts.

The focused test command and reproduction workflow are in [CONTRIBUTING](../CONTRIBUTING.md).
