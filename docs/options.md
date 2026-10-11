# Existing options reviewed — 11 October 2026

These are public product/documentation claims; paid plans and authenticated collaboration were not purchased or tested.

| Option | Google/browser identity | Indian multi-event planning and collaboration | Assessment |
| --- | --- | --- | --- |
| [WedSites](https://wedsites.com/pricing/) | [Google account signup documented](https://help.wedsites.com/en/articles/14455507-creating-your-account) | Multi-event RSVPs and configurable team permissions; feature and team limits vary by plan | Closest documented ready-made match. Paid plans; check current price and hosting duration. [Plan details](https://help.wedsites.com/en/articles/14456334-what-features-are-included-in-each-plan), [team permissions](https://help.wedsites.com/en/articles/14456330-how-do-i-manage-team-permissions). |
| [itsmy.wedding](https://itsmy.wedding/tools) | Google signup not verified | Advertises Indian multi-event tools, a co-planner and family collaboration | Worth evaluating if a hosted service is preferred. |
| [WedSetGo](https://wedsetgo.app/) | Google button visible on its [login page](https://wedsetgo.app/dashboard) | Advertises Indian celebrations and family collaboration | Public claims fit; authenticated flows not tested. |
| [WeddingWire India](https://www.weddingwire.in/my-wedding-planner) | Google login in a browser not established by the reviewed documentation | Free planning tools and [partner account linking](https://help.weddingwire.in/hc/en-us/articles/51283897920660-How-do-I-link-my-account-with-my-partner) | Familiar vendor ecosystem; broader team permissions need confirmation. |

## Source alternatives

| Project | License evidence | Fit and gaps |
| --- | --- | --- |
| [LibreWeddingPlanner](https://libreweddingplanner.org/) | AGPL-3.0 license in the backend and frontend repositories | Selected foundation: existing guests, expenses, RSVP tools and confirmed-membership sharing. Adds the most reliable reusable foundation; required a new UI, multi-event model and Google identity adapter. [Team settings](https://libreweddingplanner.org/docs/settings/), [login](https://libreweddingplanner.org/docs/login/). |
| [eyalsegev123/WeddingPlanner](https://github.com/eyalsegev123/WeddingPlanner) | No license file found when reviewed | React/Supabase with similar planning features, but reuse rights were unclear. No code reused. |
| [segyhp/wedding-planner](https://github.com/segyhp/wedding-planner) | README claimed MIT; no license file found | Rust/Vue/Postgres implementation; more integration work and unclear licensing evidence. No code reused. |
| [Soccerbeats/weddingwebsite](https://github.com/Soccerbeats/weddingwebsite) | PolyForm Noncommercial | Source available, with noncommercial restrictions; not an open-source license. No code reused. |

The chosen adaptation retains the Rails data/membership foundation and replaces the planning UI. Collaboration currently follows the upstream full-access member model; fine-grained roles and guest self-service per-event RSVP pages are outside this version.
