---
name: nextjs-cache-invalidation-contracts
description: "Repair Next.js App Router cache scope and mutation/read consistency on the project's installed cache model."
---

# Nextjs Cache Invalidation Contracts

## Decisions And Evidence

1. Identify whether Cache Components is enabled; do not mix that contract with legacy fetch/unstable_cache defaults.
2. Test tagged invalidation and read-after-write behavior through server and client caches with tenant isolation.

## Boundary

Do not change framework versions to make an API example fit.

## Source

[Current primary reference](https://nextjs.org/docs/app/getting-started/revalidating). Check the installed version and current contract before execution.
