"""Compare MCP tool inventories without treating annotations as authorization."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def tools_by_name(data: dict) -> dict:
    rows = data.get("tools", data.get("result", {}).get("tools"))
    if not isinstance(rows, list):
        raise ValueError("expected a tools/list object")
    result = {}
    for row in rows:
        name = row.get("name")
        if not isinstance(name, str) or not name or name in result:
            raise ValueError("missing or duplicate tool name")
        result[name] = row
    return result


def fingerprint(value: dict) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def compare(baseline: dict, current: dict, allowed_reads: set[str]) -> dict:
    old, new = tools_by_name(baseline), tools_by_name(current)
    changed = [name for name in sorted(old.keys() & new.keys()) if fingerprint(old[name]) != fingerprint(new[name])]
    added, removed = sorted(new.keys() - old.keys()), sorted(old.keys() - new.keys())
    unknown = sorted(new.keys() - allowed_reads)
    return {"added": added, "removed": removed, "changed": changed,
            "outside_read_allowlist": unknown,
            "review_required": bool(added or removed or changed or unknown),
            "baseline_sha256": fingerprint(baseline), "current_sha256": fingerprint(current),
            "authorization": "not-granted", "automatic_calls": False,
            "claim_boundary": "Names, schemas and readOnlyHint are untrusted inventory, not proof of read-only behavior."}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--current", type=Path, required=True)
    parser.add_argument("--allow-read", action="append", default=[])
    parser.add_argument("--fail-on-review", action="store_true")
    args = parser.parse_args()
    try:
        result = compare(json.loads(args.baseline.read_text(encoding="utf-8-sig")),
                         json.loads(args.current.read_text(encoding="utf-8-sig")), set(args.allow_read))
        print(json.dumps(result, indent=2))
        return int(args.fail_on_review and result["review_required"])
    except (ValueError, OSError) as exc:
        print(f"MCP inventory: FAIL: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
