---
name: file-upload-storage-pipeline
description: "Use this skill for uploads, storage, validation, metadata, signed URLs, malware checks, quotas."
---

# File Upload Storage Pipeline

## Task Decisions

1. Validate size, MIME/content agreement and authorization before storage; isolate processing of untrusted files.
2. Test expired signed URLs, cross-tenant object access, retries and deletion retention without publishing private uploads.

Use this skill for Programming tasks focused on uploads, storage, validation, metadata, signed URLs, malware checks, quotas.

## Guardrails

- Do not trust client-provided MIME types, paths, or filenames.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
