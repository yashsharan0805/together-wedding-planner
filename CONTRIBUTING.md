# Contributing to Together

Start with [README](README.md), [architecture](docs/architecture.md), [Google sign-in](docs/google-sign-in.md) and [security](SECURITY.md). Contributions to this fork use its AGPL license; preserve upstream headers and separately licensed asset notices. This is an independent adaptation, not an endorsed upstream release. Upstream has its own contribution policy; do not assume this fork's contributions will be accepted there.

Use a feature branch, synthetic data and your own local Google client. Describe the user-visible change, validation and any remaining limits in the pull request. Do not post real wedding data or provider configuration in issues, fixtures, screenshots or logs.

## Development loop

```sh
cp .env.example .env
# Fill GOOGLE_CLIENT_ID using the Google guide.
docker compose -f compose.yml up --build -d
```

Edit `dist/app.js`/`dist/styles.css` for the buildless UI and `backend/` for Rails. The local stack mounts these sources. Open http://localhost:8080. For syntax/whitespace checks:

```sh
node --input-type=module --check < dist/app.js
git diff --check
```

Run focused requests against the separate test database, never production:

```sh
docker compose -f compose.yml run --rm \
  -e RAILS_ENV=test \
  -e DATABASE_URL=postgres://postgres:local-development-only@db:5432/together_test \
  backend bash -lc 'bundle install && bin/rails db:create db:migrate && bundle exec rspec spec/requests/together_planner_spec.rb spec/requests/google_sessions_spec.rb'
```

These specs mock Google verification. A browser login check must separately use a real signed ID token. For collaboration changes, verify two authorized accounts, tenant isolation and conflicting edits. For attachments, verify upload/download/removal, invalid files, quotas, CSRF and persistence. Use disposable synthetic fixtures and clean up only those fixtures.

Before release, regenerate and scan corresponding source, then check a production-mode container boots. A successful image build alone does not prove runtime dependencies load. Migrate deliberately, without upstream seeds, and publish the exact source corresponding to the deployed code. See [open-source publication](docs/open-source.md).
