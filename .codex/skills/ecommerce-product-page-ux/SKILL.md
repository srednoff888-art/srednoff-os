---
name: ecommerce-product-page-ux
description: "Use this skill for product detail pages, media galleries, variants, inventory, trust, conversion."
---

# Ecommerce Product Page UX

## Task Decisions

1. Keep variant, price, stock, dimensions, delivery and media tied to the same selected SKU.
2. Test unavailable combinations, long option names, gallery controls and cart validation with real product data.

Use this skill for Web Design tasks focused on product detail pages, media galleries, variants, inventory, trust, conversion.

## Guardrails

- Do not hide price, availability, shipping, or return-critical information.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
