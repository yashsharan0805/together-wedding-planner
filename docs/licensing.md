# License review and dependency inventory

Reviewed 11 October 2026. Together is an independent AGPL version 3 adaptation; preserve LICENSE/COPYING/NOTICE and upstream headers. [Publication requirements](open-source.md) explains the network source offer. Each dependency/asset keeps its own applicable license.

## Ruby dependencies

[The inventory](dependency-licenses.json) records 184 resolved gems, including 138 in the default dependency group, their versions/license metadata and the Gemfile.lock hash. It was read from the installed local development gems, without installing anything or accessing wedding data. Default-group classification approximates production dependency scope; it is not a binary contents manifest.

- Missing metadata for `acts_as_tenant` and `imgkit` was checked against installed README/LICENSE notices and resolved to MIT.
- `diff-lcs` offers MIT as a licensing alternative; `rdoc` offers Ruby licensing alongside GPL. They do not force choosing the GPL alternative.
- **Sidekiq 8.1.7 is LGPLv3.** It remains an installed upstream dependency even though the supported hosted planner uses no background worker. Preserve its notices and the applicable license texts; review its corresponding-source and library replacement requirements when distributing container images. [Versioned Sidekiq license](https://github.com/sidekiq/sidekiq/blob/v8.1.7/LICENSE.txt), [GNU LGPL](https://www.gnu.org/licenses/lgpl-3.0.html).

No obvious mandatory incompatible gem license was found from metadata and those targeted notices. This is not complete legal clearance. Rebuild the inventory when the lockfile changes, and review any bundled dependency's actual license/source obligations; the JSON report does not satisfy them by itself.

## Assets and remaining scope

Cinzel, Dancing Script and Monsieur La Doulaise retain their bundled SIL Open Font License/copyright files. Keep those files when redistributing fonts. [Official OFL](https://openfontlicense.org/open-font-license-official-text/).

The unused upstream frontend and its CC BY-ND illustrations are omitted from the export. The retained backend sample invitation photo comes from the documented upstream base commit but has no separate attribution in the local checkout; its individual provenance remains to be confirmed before declaring a complete asset review. NOTICE records this limitation.

Operating-system packages, container base images, native libraries/tools and the full dependency-source offer have not been exhaustively audited. Before a tagged public image release, inventory its actual contents and collect any required notices, licenses and source/offers. Do not infer that all transitive/native packages are permissively licensed merely because the application is open source. Provider plans and Google/Vercel/Neon service terms remain separate from source licenses.
