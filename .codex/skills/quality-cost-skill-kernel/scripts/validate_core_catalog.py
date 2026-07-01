#!/usr/bin/env python3
"""Validate the quality/cost capability catalog."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path


REQUIRED_FIELDS = {
    "id",
    "name",
    "kind",
    "group",
    "group_label",
    "domain_id",
    "domain",
    "capability_slug",
    "title",
    "description",
    "use_when",
    "avoid_when",
    "selection_terms",
    "file_signals",
    "expected_output",
    "activation",
    "cost_rule",
    "non_overlap_boundary",
}

EXPECTED_TOTAL = 4500
EXPECTED_GROUPS = {1: 1800, 2: 1800, 3: 900}
EXPECTED_DOMAIN_RECORDS = 75
EXPECTED_DOMAIN_GROUPS = {1: 30, 2: 30, 3: 15}


def fail(message: str) -> None:
    raise SystemExit(f"validation failed: {message}")


def main() -> int:
    parser = argparse.ArgumentParser()
    default_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--catalog", default=str(default_root / "references" / "core-3000-capabilities.json"))
    args = parser.parse_args()

    catalog_path = Path(args.catalog)
    if not catalog_path.exists():
        fail(f"catalog not found: {catalog_path}")

    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    if len(catalog) != EXPECTED_TOTAL:
        fail(f"expected {EXPECTED_TOTAL} records, got {len(catalog)}")

    ids = [record.get("id") for record in catalog]
    names = [record.get("name") for record in catalog]
    if len(ids) != len(set(ids)):
        duplicates = [item for item, count in Counter(ids).items() if count > 1]
        fail(f"duplicate ids: {duplicates[:10]}")
    if len(names) != len(set(names)):
        duplicates = [item for item, count in Counter(names).items() if count > 1]
        fail(f"duplicate names: {duplicates[:10]}")

    group_counts = Counter(record.get("group") for record in catalog)
    if dict(group_counts) != EXPECTED_GROUPS:
        fail(f"group counts mismatch: expected {EXPECTED_GROUPS}, got {dict(group_counts)}")

    domain_slug_pairs = [(record.get("domain_id"), record.get("capability_slug")) for record in catalog]
    if len(domain_slug_pairs) != len(set(domain_slug_pairs)):
        fail("duplicate domain/capability_slug pairs")

    domain_counts = Counter(record.get("domain_id") for record in catalog)
    bad_domains = {
        domain: count
        for domain, count in domain_counts.items()
        if count != EXPECTED_DOMAIN_RECORDS
    }
    if bad_domains:
        fail(f"domain record counts mismatch: {dict(sorted(bad_domains.items()))}")

    domains = sorted(domain_counts)
    for domain in domains:
        domain_group_counts = Counter(record.get("group") for record in catalog if record.get("domain_id") == domain)
        if dict(domain_group_counts) != EXPECTED_DOMAIN_GROUPS:
            fail(f"domain {domain} group counts mismatch: expected {EXPECTED_DOMAIN_GROUPS}, got {dict(domain_group_counts)}")

    capability_slugs = {record.get("capability_slug") for record in catalog}
    if len(capability_slugs) != EXPECTED_DOMAIN_RECORDS:
        fail(f"expected {EXPECTED_DOMAIN_RECORDS} unique capability slugs, got {len(capability_slugs)}")

    kind_counts = Counter(record.get("kind") for record in catalog)
    for index, record in enumerate(catalog, start=1):
        missing = REQUIRED_FIELDS - set(record)
        if missing:
            fail(f"record {index} missing fields: {sorted(missing)}")
        if record["kind"] not in {"skill", "agent"}:
            fail(f"record {record['id']} has invalid kind: {record['kind']}")
        if not isinstance(record["selection_terms"], list) or len(record["selection_terms"]) < 5:
            fail(f"record {record['id']} needs at least 5 selection terms")
        if not isinstance(record["file_signals"], list) or not record["file_signals"]:
            fail(f"record {record['id']} needs file signals")
        for field in ("title", "description", "use_when", "avoid_when", "expected_output"):
            if not str(record.get(field, "")).strip():
                fail(f"record {record['id']} has empty {field}")

    print("catalog ok")
    print(f"records: {len(catalog)}")
    print(f"groups: {dict(sorted(group_counts.items()))}")
    print(f"kinds: {dict(sorted(kind_counts.items()))}")
    print(f"domains: {len(domains)}")
    print(f"capability_slugs: {len(capability_slugs)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
