"""Determine the next stable app version for the release workflow."""

import os
from pathlib import Path
import re
import subprocess


VERSION_PATTERN = re.compile(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")


def parse_version(value: str) -> tuple[int, int, int] | None:
    match = VERSION_PATTERN.fullmatch(value)
    if match is None:
        return None
    return tuple(map(int, match.groups()))


def format_version(value: tuple[int, int, int]) -> str:
    return ".".join(map(str, value))


def main() -> None:
    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    base_match = re.search(r"^version:\s*([^\s]+)", pubspec, re.MULTILINE)
    if base_match is None:
        raise SystemExit("pubspec.yaml has no valid version field")

    base_version = base_match.group(1).split("+", maxsplit=1)[0]
    base = parse_version(base_version)
    if base is None:
        raise SystemExit(f"Invalid base version in pubspec.yaml: {base_version}")

    if os.environ.get("GITHUB_REF_TYPE") == "tag":
        ref_name = os.environ.get("GITHUB_REF_NAME", "")
        requested = ref_name.removeprefix("v")
        version = parse_version(requested)
        if version is None:
            raise SystemExit(f"Release tags must use the stable vMAJOR.MINOR.PATCH format: {ref_name}")
    else:
        tags = subprocess.run(
            ["git", "tag", "--list", "v*"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.splitlines()
        released = [parse_version(tag[1:]) for tag in tags if tag.startswith("v")]
        latest = max([base, *(version for version in released if version is not None)])
        version = (latest[0], latest[1], latest[2] + 1)

    build_number_text = os.environ.get("GITHUB_RUN_NUMBER", "")
    if not build_number_text.isdigit() or int(build_number_text) <= 0:
        raise SystemExit("GITHUB_RUN_NUMBER must be a positive integer")

    value = format_version(version)
    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with open(output, "a", encoding="utf-8") as file:
            file.write(f"version={value}\n")
            file.write(f"tag=v{value}\n")
    else:
        print(f"version={value}")
        print(f"tag=v{value}")


if __name__ == "__main__":
    main()
