---
name: search-indexing-rag
description: "Use this skill for search indexing, embeddings, RAG chunking, freshness, retrieval evaluation, source citations."
---

# Search Indexing RAG

## Task Decisions

1. Track document version, chunk/source identity, permissions and deletion propagation through retrieval.
2. Evaluate retrieval relevance and grounded answers separately; never return chunks the caller is not authorized to read.

Use this skill for AI Engineering tasks focused on search indexing, embeddings, RAG chunking, freshness, retrieval evaluation, source citations.

## Guardrails

- Do not mix trusted and untrusted retrieval sources without boundaries.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
