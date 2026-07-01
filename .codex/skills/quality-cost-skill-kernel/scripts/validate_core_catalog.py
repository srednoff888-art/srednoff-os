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

EXPECTED_GROUPS = {1: 1200, 2: 1200, 3: 600}


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
    if len(catalog) != 3000:
        fail(f"expected 3000 records, got {len(catalog)}")

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
    print(f"domains: {len(set(record['domain_id'] for record in catalog))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
