---
name: google-ads-offline-conversion-reconciliation
description: "Reconcile CRM outcomes with Google offline conversion imports and attribution diagnostics."
---

# Google Ads Offline Conversion Reconciliation

## Decisions And Evidence

1. Check current Data Manager versus legacy upload eligibility before implementing an ingestion path.
2. Compare stable event/order identity, consent, timestamps, currency, partial failures and accepted versus attributed outcomes.

## Boundary

Use synthetic or redacted fixtures; an import, deletion or adjustment in a real account requires approval.

## Source

[Current primary reference](https://developers.google.com/google-ads/api/docs/conversions/overview). Check the installed version and current contract before execution.
