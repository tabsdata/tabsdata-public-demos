#!/usr/bin/env python3
"""Interactive component selector for setup/stop scripts."""

from __future__ import annotations

import argparse
from pathlib import Path
import signal
import sys


COMPONENTS = [
    ("hashicorp", "hashicorp"),
    ("log_file", "log file"),
    ("mysql", "mysql"),
    ("redpanda", "redpanda"),
    ("tabsdata", "tabsdata"),
]


def _stderr(msg: str) -> None:
    print(msg, file=sys.stderr)


def _questionary_select(mode: str) -> list[str]:
    from InquirerPy import inquirer

    choices = [{"name": label, "value": value, "enabled": True} for value, label in COMPONENTS]
    result = inquirer.checkbox(
        message=f"Select components to {mode}:",
        choices=choices,
        instruction="(All selected by default. Space toggles. Enter confirms.)",
        cycle=False,
    ).execute()
    return result or []


def select_components(mode: str) -> list[str]:
    if not sys.stdin.isatty():
        return [value for value, _ in COMPONENTS]
    try:
        return _questionary_select(mode)
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "InquirerPy is required for interactive selection. "
            "Install it with: python3 -m pip install InquirerPy"
        ) from exc


def _questionary_confirm() -> bool:
    from InquirerPy import inquirer

    return bool(
        inquirer.confirm(
            message="Destroy Tabsdata instance as well?",
            default=False,
        ).execute()
    )


def confirm_destroy() -> bool:
    if not sys.stdin.isatty():
        return False
    try:
        return _questionary_confirm()
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "InquirerPy is required for interactive confirmation. "
            "Install it with: python3 -m pip install InquirerPy"
        ) from exc


def _emit_lines(values: list[str], out_file: str | None) -> None:
    payload = "\n".join(values)
    if payload:
        payload += "\n"
    if out_file:
        Path(out_file).write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")


def _emit_text(value: str, out_file: str | None) -> None:
    payload = value + "\n"
    if out_file:
        Path(out_file).write_text(payload, encoding="utf-8")
    else:
        print(value)


def main() -> int:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    select_parser = subparsers.add_parser("select")
    select_parser.add_argument("--mode", choices=["setup", "stop"], required=True)
    select_parser.add_argument("--out-file")

    confirm_parser = subparsers.add_parser("confirm-destroy")
    confirm_parser.add_argument("--out-file")

    args = parser.parse_args()

    if args.command == "select":
        try:
            try:
                _emit_lines(select_components(args.mode), args.out_file)
            except BrokenPipeError:
                return 0
            return 0
        except RuntimeError as exc:
            _stderr(str(exc))
            return 3

    if args.command == "confirm-destroy":
        try:
            _emit_text("true" if confirm_destroy() else "false", args.out_file)
        except BrokenPipeError:
            return 0
        except RuntimeError as exc:
            _stderr(str(exc))
            return 3
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
