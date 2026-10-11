# Publishing Together on GitHub

## Recommended repository layout

Publish a **clean monorepo** containing the custom UI, adapted Rails backend, deployment scripts, templates, tests and documentation. The original development workspace has separate nested Git repositories and ignores `backend/`; pushing its root directly would omit the adapted implementation. The export tool flattens backend source without copying nested Git metadata or private history. The unused upstream frontend is omitted.

Publication is not performed by any export/check command. No GitHub repository is created, pushed or made public automatically.

## License and attribution requirements

Together adapts LibreWeddingPlanner under GNU AGPL version 3; this fork must retain its applicable license obligations. Do not relabel the combined adaptation as MIT/Apache or remove upstream notices. Preserve LICENSE/COPYING verbatim, copyright headers, NOTICE's upstream origin/base commit and dated modification summary. Contributions to this fork should use the same applicable license.

Remote users of a modified AGPL application must receive a prominent, free offer of its corresponding source. Keep the app's footer Source link and generate the archive from the exact release's code, migrations, configuration templates and build/install scripts. A public GitHub repository is useful but not itself the license requirement. Runtime credentials, authentication keys, wedding records and uploaded files are not public source; operators provide their own configuration. [GNU AGPL section 13](https://www.gnu.org/licenses/agpl-3.0.html), [GNU FAQ](https://www.gnu.org/licenses/gpl-faq.en.html#AGPLv3InteractingRemotely).

Third-party license obligations remain: preserve the three bundled fonts' OFL/copyright files. The unused upstream frontend's CC BY-ND artwork is not included. The retained upstream backend sample photo has no separate local attribution; review its provenance before claiming a complete asset audit. Inventory dependency licenses and any required source/notices/offers for each release; a lockfile alone is not a substitute for those obligations. A Ruby metadata and targeted-notice inventory covers 184 gems and found no obvious mandatory incompatible license; Sidekiq is LGPLv3. Native/container dependency and complete source-offer review remain. See [the licensing review](licensing.md). [OFL text](https://openfontlicense.org/open-font-license-official-text/), [corresponding-source FAQ](https://www.gnu.org/licenses/gpl-faq.en.html#AGPLv3CorrespondingSource).

For public branding, identify this as an independent adaptation, preserve provenance and avoid implying upstream endorsement. Upstream maintains its own contribution policy, including restrictions on AI contributions; that does not establish this fork as an upstream submission.

## Credential and privacy requirements

- Create your own Google client, database and session secret. Never reuse the maintainer's credentials.
- Commit only blank/safe environment templates. Keep real values in protected host settings and ignored local files.
- Exclude CLI tokens, OAuth JSON downloads, Rails keys/encrypted credentials, certificates, database dumps, runtime documents, screenshots/logs and provider account links.
- Inspect **Git history and source archives**, not just the current file tree. Enable GitHub secret scanning/push protection and the included CI checks. See [SECURITY](../SECURITY.md).
- Do not include a production database or secrets in public PR/Actions testing. Every installation and preview environment gets separate runtime configuration.

The local audit found no production DB/session secrets in the inspected history/source/served archive. Old documentation did reveal personal account information, which has been generalized. Existing histories still contain old versions; use the clean export rather than pushing them. Personal data in previously distributed archives cannot be recalled.

## Prepare a reviewable export

Run from the existing development workspace:

```sh
python3 scripts/package-source.py
python3 scripts/check-public-source.py
python3 scripts/prepare-public-repo.py
```

The last command creates `output/public-repo` and refuses to overwrite it. After further edits, choose a new destination, for example `--destination output/public-repo-next`. Check its README, templates, NOTICE and backend files. Source tooling works before Git initialization and in an ordinary public clone; it does not require a nested upstream checkout.

Scan this directory with the pinned Gitleaks image/commands in `.github/workflows/security.yml`. Archive scanning must be enabled. After initializing Git, scan that history too. Scanner output is redacted; a failed scan blocks publication. Pattern scanning cannot identify every arbitrary private value, so also review new documents/configuration manually.

## Create and publish when ready

These are manual instructions, not actions already performed. From the **export directory**, use a new repository and fresh history:

```sh
cd output/public-repo
git init -b main
# Configure your chosen author identity, preferably your GitHub noreply address.
git config user.name "YOUR_NAME"
git config user.email "YOUR_GITHUB_NOREPLY_ADDRESS"
git add .
git diff --cached --stat
python3 scripts/check-public-source.py
git commit -m "Publish Together wedding planner"
# Run the history scanner before the first push.
gh repo create YOUR_ACCOUNT/YOUR_REPOSITORY --private --source=. --remote=origin
git push -u origin main
```

Start private for review if desired, but still do not push secrets. Check that `backend/` contains real source rather than a gitlink. Verify a fresh clone can run the documented local stack with a new Google client. After the release checklist passes, change visibility to public through the repository settings. AGPL source must still be available to users of the running modified service while GitHub is private.

Configure secret scanning/push protection, private vulnerability reporting, default-branch checks and contribution settings available under your account/plan. The included CI uses read-only permissions, does not persist checkout credentials, and has pinned action/image versions. No production deployment credentials are needed for the security job. [GitHub licensing](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository), [secret scanning](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope), [Actions security](https://docs.github.com/en/actions/reference/security/secure-use).

## Before a public release

1. Complete the dependency/asset licensing review; preserve the notices and complete corresponding source.
2. Pass source/archive/history scans and inspect docs/fixtures for private data.
3. Run the focused tests and a production boot check; verify Google login and membership isolation with your own configuration.
4. Replace the live source archive with the cleaned exact-release archive. Do not remove the source offer during redeployment.
5. Add a release tag and describe supported features, remaining limitations and installation requirements honestly. Configure a private security reporting channel.

Source is reusable under its license. Free provider plans and service agreements remain separate; Vercel Hobby's personal/noncommercial restrictions are not a restriction added to the software license. Anyone hosting for other people also needs their own privacy, data-retention and backup arrangements.
