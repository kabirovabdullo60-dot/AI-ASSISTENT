#!/usr/bin/env python3
"""Regenerate API.md from the live Swagger of Mehroj's backend.

    python3 scripts/gen_api_md.py            # fetches /openapi.json, rewrites API.md
    python3 scripts/gen_api_md.py spec.json  # from a saved spec

The hand-written part at the top of API.md (everything before "## Endpoints overview": the
connection rules and the screen table) is kept as it is; edit it by hand. Everything after it
is generated: the endpoint overview, each endpoint by tag, the schemas and the error codes.
Run it on `main` (API.md changes only there), then commit.
"""
import json
import re
import sys
import urllib.request
from pathlib import Path

BASE = "https://api-production-86caefb2.up.railway.app"
ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "API.md"
MARK = "## Endpoints overview"


def load_spec():
    if len(sys.argv) > 1:
        return json.loads(Path(sys.argv[1]).read_text())
    req = urllib.request.Request(BASE + "/openapi.json", headers={"User-Agent": "api-md-generator"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


def ref_name(ref):
    return ref.split("/")[-1]


def type_str(s):
    if not s:
        return ""
    if "$ref" in s:
        return ref_name(s["$ref"])
    if "anyOf" in s:
        return " \\| ".join(type_str(x) for x in s["anyOf"])
    if "allOf" in s and len(s["allOf"]) == 1:
        return type_str(s["allOf"][0])
    t = s.get("type", "")
    if t == "array":
        return type_str(s.get("items", {})) + "[]"
    if t == "null":
        return "null"
    if s.get("format") and t == "string":
        return f"string ({s['format']})"
    return t or "object"


def constraints(s):
    out = []
    flat = [s] + [x for x in s.get("anyOf", []) if isinstance(x, dict)]
    for x in flat:
        for k in ("minLength", "maxLength", "minimum", "maximum", "exclusiveMinimum", "minItems", "maxItems", "pattern"):
            if k in x:
                out.append(f"{k}=`{x[k]}`")
        if "enum" in x and x is not s:
            pass
    if "enum" in s:
        out.append("one of " + ", ".join(f"`{v}`" for v in s["enum"]))
    if "default" in s and s["default"] is not None:
        d = json.dumps(s["default"]) if not isinstance(s["default"], str) else s["default"]
        out.append(f"default=`{d}`")
    if "const" in s:
        out.append(f"const=`{s['const']}`")
    return ", ".join(dict.fromkeys(out))


def clean(text):
    return re.sub(r"\s*\n\s*", " ", (text or "").strip()).replace("|", "\\|")


def secured(op, spec):
    return bool(op.get("security", spec.get("security")))


def endpoint_md(method, path, op, spec):
    lock = " 🔒" if secured(op, spec) else ""
    lines = [f"### `{method.upper()} {path}`{lock}", "", f"**{op.get('summary', '')}**", ""]
    if op.get("description"):
        lines += [op["description"].strip(), ""]
    params = op.get("parameters", [])
    if params:
        lines += ["| Param | In | Type | Required | Notes |", "|---|---|---|---|---|"]
        for p in params:
            sch = p.get("schema", {})
            note = f"{clean(p.get('description') or sch.get('description'))} {constraints(sch)}"
            lines.append(f"| `{p['name']}` | {p['in']} | {type_str(sch)} | {'yes' if p.get('required') else ''} | {note} |")
        lines.append("")
    body = op.get("requestBody", {}).get("content", {})
    for ctype, c in body.items():
        lines += [f"Body (`{ctype}`): **{type_str(c.get('schema', {}))}**", ""]
    lines.append("Responses:")
    for code, r in op.get("responses", {}).items():
        sch = (r.get("content", {}).get("application/json") or {}).get("schema")
        tail = f" → **{type_str(sch)}**" if sch else ""
        lines.append(f"- `{code}` {clean(r.get('description', ''))}{tail}")
    return "\n".join(lines) + "\n"


def schema_md(name, s):
    lines = [f"### {name}", ""]
    if s.get("description"):
        lines += [s["description"].strip(), ""]
    if "enum" in s:
        lines += ["Enum: " + ", ".join(f"`{v}`" for v in s["enum"]), ""]
        return "\n".join(lines)
    props = s.get("properties", {})
    if props:
        req = set(s.get("required", []))
        lines += ["| Field | Type | Required | Notes |", "|---|---|---|---|"]
        for k, v in props.items():
            note = f"{clean(v.get('description'))} {constraints(v)}"
            lines.append(f"| `{k}` | {type_str(v)} | {'yes' if k in req else ''} | {note} |")
        lines.append("")
    return "\n".join(lines)


def main():
    spec = load_spec()
    old = TARGET.read_text() if TARGET.exists() else ""
    intro = old.split(MARK)[0] if MARK in old else "# API\n\n"
    tags = [t["name"] for t in spec.get("tags", [])]
    tag_desc = {t["name"]: t.get("description", "") for t in spec.get("tags", [])}
    by_tag = {}
    for path, ops in spec["paths"].items():
        for method, op in ops.items():
            tag = (op.get("tags") or ["Other"])[0]
            by_tag.setdefault(tag, []).append((method, path, op))
            if tag not in tags:
                tags.append(tag)

    out = [intro.rstrip() + "\n", MARK, "", "| Auth | Method | Path | What |", "|---|---|---|---|"]
    for tag in tags:
        for method, path, op in by_tag.get(tag, []):
            out.append(f"| {'🔒' if secured(op, spec) else ''} | `{method.upper()}` | `{path}` | {clean(op.get('summary', ''))} |")
    out.append("")
    for tag in tags:
        if tag not in by_tag:
            continue
        out += [f"## {tag}", ""]
        if tag_desc.get(tag):
            out += [tag_desc[tag].strip(), ""]
        for method, path, op in by_tag[tag]:
            out.append(endpoint_md(method, path, op, spec))
    out += ["## Schemas", ""]
    for name in sorted(spec["components"]["schemas"]):
        out.append(schema_md(name, spec["components"]["schemas"][name]))
    codes = {}
    for ops in spec["paths"].values():
        for op in ops.values():
            for http, r in op.get("responses", {}).items():
                for code, ex in (r.get("content", {}).get("application/json", {}).get("examples") or {}).items():
                    codes.setdefault((int(http), code), ex.get("summary", ""))
    out += ["## Error codes", "", "| HTTP | code | meaning |", "|---|---|---|"]
    for (http, code), text in sorted(codes.items()):
        out.append(f"| {http} | `{code}` | {clean(text)} |")
    out += ["", "---", "Questions about the API → Mehroj (backend). If something here differs from the live Swagger, "
            "the Swagger wins — regenerate this file with `python3 scripts/gen_api_md.py`.", ""]
    TARGET.write_text("\n".join(out))
    print(f"API.md: {len(spec['paths'])} paths, {len(spec['components']['schemas'])} schemas, {len(codes)} error codes")


if __name__ == "__main__":
    main()
