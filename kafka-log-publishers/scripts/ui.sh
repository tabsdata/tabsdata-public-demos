#!/bin/bash
#
# Shared terminal UI helpers for setup scripts.
#

if [ -z "${UI_SH_LOADED:-}" ]; then
  UI_SH_LOADED=1

  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    UI_BOLD="\033[1m"
    UI_RESET="\033[0m"
    UI_RED="\033[31m"
    UI_GREEN="\033[32m"
    UI_YELLOW="\033[33m"
    UI_BLUE="\033[34m"
    UI_CYAN="\033[36m"
  else
    UI_BOLD=""
    UI_RESET=""
    UI_RED=""
    UI_GREEN=""
    UI_YELLOW=""
    UI_BLUE=""
    UI_CYAN=""
  fi

  print_divider() {
    printf "%b\n" "${UI_BLUE}============================================================${UI_RESET}"
  }

  print_header() {
    echo
    print_divider
    printf "%b\n" "${UI_BOLD}${UI_BLUE}$1${UI_RESET}"
    print_divider
  }

  print_step() {
    printf "%b\n" "${UI_CYAN}[..]${UI_RESET} $1"
  }

  print_success() {
    printf "%b\n" "${UI_GREEN}[OK]${UI_RESET} $1"
  }

  print_warning() {
    printf "%b\n" "${UI_YELLOW}[WARN]${UI_RESET} $1"
  }

  print_error() {
    printf "%b\n" "${UI_RED}[ERR]${UI_RESET} $1"
  }

  print_kv() {
    printf "  %b%-18s%b %s\n" "${UI_BOLD}" "$1:" "${UI_RESET}" "$2"
  }

  run_cmd() {
    local label="$1"
    shift
    print_step "${label}"
    "$@" 2>&1 | sed 's/^/    | /'
    local rc=${PIPESTATUS[0]}
    if [ "${rc}" -ne 0 ]; then
      print_error "${label} failed"
      return "${rc}"
    fi
    print_success "${label}"
  }

  run_cmd_sh() {
    local label="$1"
    shift
    local cmd="$*"
    print_step "${label}"
    eval "${cmd}" 2>&1 | sed 's/^/    | /'
    local rc=${PIPESTATUS[0]}
    if [ "${rc}" -ne 0 ]; then
      print_error "${label} failed"
      return "${rc}"
    fi
    print_success "${label}"
  }
fi
