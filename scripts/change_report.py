#!/usr/bin/env python3
"""Create a compact Markdown report for one Git commit range.

The report is used locally and in GitHub Actions so every change has the same
file/line summary and direct links to the file history.
"""
from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path
from urllib.parse import quote

DEFAULT_REPOSITORY = "Wasserwolke/founder-sim"
DEFAULT_BRANCH = "main"


def run_git(*args: str) -> str:
    """Run Git and return trimmed stdout, raising on command errors."""
    result = subprocess.run(
        ["git", *args],
        check=True,
        text=True,
        capture_output=True,
    )
    return result.stdout.strip()


def repository_slug() -> str:
    """Resolve owner/repository from origin, falling back to Founder Sim."""
    try:
        remote = run_git("config", "--get", "remote.origin.url")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return DEFAULT_REPOSITORY

    remote = remote.removesuffix(".git")
    if remote.startswith("git@github.com:"):
        return remote.split(":", 1)[1]
    marker = "github.com/"
    if marker in remote:
        return remote.split(marker, 1)[1]
    return DEFAULT_REPOSITORY


def changed_files(base: str, head: str) -> list[tuple[str, str, str]]:
    """Return path plus added/deleted line counts for the requested range."""
    output = run_git("diff", "--numstat", base, head, "--")
    rows: list[tuple[str, str, str]] = []
    for line in output.splitlines():
        if not line.strip():
            continue
        added, deleted, path = line.split("\t", 2)
        rows.append((path, added, deleted))
    return rows


def build_report(base: str, head: str, branch: str) -> str:
    """Build the Markdown shown in terminal output and GitHub Actions Summary."""
    repo = repository_slug()
    short_sha = run_git("rev-parse", "--short", head)
    subject = run_git("log", "-1", "--format=%s", head)
    commit_sha = run_git("rev-parse", head)
    commit_url = f"https://github.com/{repo}/commit/{commit_sha}"

    lines = [
        "## Founder Sim - Change Report",
        "",
        f"Commit: [`{short_sha}`]({commit_url}) - {subject}",
        "",
        "| Datei | Zeilen | History |",
        "|---|---:|---|",
    ]

    for path, added, deleted in changed_files(base, head):
        encoded_path = quote(path, safe="/")
        file_url = f"https://github.com/{repo}/blob/{commit_sha}/{encoded_path}"
        history_url = f"https://github.com/{repo}/commits/{branch}/{encoded_path}"
        counts = "binary" if added == "-" or deleted == "-" else f"+{added}/-{deleted}"
        lines.append(f"| [`{path}`]({file_url}) | {counts} | [History]({history_url}) |")

    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    """Parse commit range and optional GitHub Summary output switch."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="HEAD^", help="Base commit/ref")
    parser.add_argument("--head", default="HEAD", help="Head commit/ref")
    parser.add_argument(
        "--branch",
        default=os.getenv("GITHUB_REF_NAME", DEFAULT_BRANCH),
        help="Branch used for GitHub file-history links",
    )
    parser.add_argument(
        "--github-summary",
        action="store_true",
        help="Append the report to GITHUB_STEP_SUMMARY when available",
    )
    return parser.parse_args()


def main() -> None:
    """Print the report and optionally append it to the Actions run summary."""
    args = parse_args()
    report = build_report(args.base, args.head, args.branch)
    print(report, end="")

    if args.github_summary:
        summary_path = os.getenv("GITHUB_STEP_SUMMARY")
        if summary_path:
            with Path(summary_path).open("a", encoding="utf-8") as handle:
                handle.write(report)


if __name__ == "__main__":
    main()
