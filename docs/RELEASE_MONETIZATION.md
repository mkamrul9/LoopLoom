# Monetization and Android launch

## Sustainable offer

Confirmed development constraint: strict zero spend using existing resources. Paid production infrastructure is a later decision after validation, not authorized by this roadmap. The launch audience is intermediate developers preparing for coding interviews.

Free: a useful original interview warm-up subset, curated hints, local practice, and basic progress. A modest hosted AI allowance is a future option only after a separate production funding decision. Offline guided practice should remain useful when AI is unavailable.

Pro: the full published roadmap library, larger bounded AI allowance, cloud sync, deeper progress/review tools, and eventually interview simulations. Do not sell unlimited inference before measuring usage. Later: university/cohort licenses and one-time curated content packs with explicitly separate AI allowances.

Avoid intrusive ads during reasoning and code entry. An optional rewarded ad for an extra cloud coaching allowance is a later experiment, contingent on audience, privacy, policy, and economics. Subscriptions are the initial monetization hypothesis.

Proposed price experiment, not a promised market price: test approximately US$4.99–7.99/month with local-currency purchasing-power adjustments and an annual offer. Decide after target-market interviews, willingness-to-pay tests, and measured costs. Never invent conversion or income expectations.

## Margin model

Contribution per payer = recognized subscription revenue after applicable store fees/refunds/taxes − coaching − judge − variable storage/hosting − variable support. Allocate the cost of free learners before declaring the business profitable. Reconcile refunds, failed renewals, and cancellations. Recheck store fee/program eligibility and tax treatment before setting prices.

Suggested internal gate: at least 60% contribution margin after the free-user allocation under realistic usage, then stress-test heavier users and lower conversion. This is a proposed business threshold, not a prediction or verified result. Founder salary, content review, development, and acquisition remain additional expenses.

## Billing implementation

Use Google Play Billing for in-app digital subscriptions where required. Exceptions and alternative billing programs depend on current policy, region, and enrollment; do not implement a universal external-checkout link. Verify purchases and entitlement changes server-side, handle restore, grace periods, account hold, refunds, and revocation, and reconcile store notifications. [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en), [subscription lifecycle](https://developer.android.com/google/play/billing/lifecycle/subscriptions).

Web billing can use a separate supported payment provider when web launches. Map purchases to one account-level entitlement while respecting the storefront's purchase and steering rules.

## Play launch sequence

1. Confirm product name, package identity, developer account type/eligibility, target age group, and launch countries. The current Play Console registration fee is US$25 once; verify accepted payment methods and identity requirements for the actual account. [Account setup](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en).
2. Secure signing keys and recovery procedures. Build a signed Android App Bundle with the target SDK and billing library versions required on the actual submission date. Recheck policy instead of treating a version number in this plan as permanent.
3. Complete real-device testing, app content declarations, Data safety answers, content rating, privacy policy, AI data disclosure, support contact, screenshots, and accurate store copy.
4. If accounts can be created, provide an in-app account deletion path and an external deletion-request page. Handle associated data and disclose justified retention. [Deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en).
5. Use internal testing, then the required closed test. For personal accounts created after 13 November 2023, current guidance requires at least 12 testers continuously opted in for 14 days before applying for production access; satisfying this threshold does not guarantee approval. Confirm account-specific requirements in Play Console. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).
6. Test subscription purchases with license testers, renewal transitions, restore, refunds, quota abuse, AI outages, slow devices, and offline recovery.
7. Release gradually, monitor crash-free sessions and backend costs, then expand rollout. Have feature flags for cloud AI and execution, a spend circuit breaker, rollback-ready content, and an incident contact.

## Acquisition

Start with 20–50 engaged learners from university clubs and interview-preparation communities. Observe actual sessions and offer founding-user pricing without making job-outcome promises. Publish original short pattern explanations and invite learners into the app. Track which channel produces retained learners, not only installs.

## Readiness definition

Production requires reviewed content, reliable coaching, isolated tested execution, durable progress, working privacy/deletion controls, verified billing, support, acceptable crash/error rates, and measured costs. The initial Flutter prototype satisfies none of these production claims by itself. All policy references were checked for this plan on 29 October 2026 and must be checked again before submission.
