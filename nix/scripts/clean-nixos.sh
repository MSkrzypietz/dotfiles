#!/usr/bin/env bash
set -Eeuo pipefail

# Remove old NixOS generations and reclaim unreachable Nix store paths.
# Safe default: retain the last 90 days and ask for confirmation.

AGE="90d"
ASSUME_YES=0
DRY_RUN=0
INCLUDE_JOURNAL=0
JOURNAL_AGE="30d"
OPTIMISE=1

usage() {
  cat <<'EOF'
Usage: scripts/clean-nixos.sh [options]

Options:
  --age AGE             Delete generations older than AGE (default: 90d).
                        Examples: 30d, 12w, 6m, 1y
  --yes                 Do not ask for confirmation.
  --dry-run             Show usage and reclaimable paths, but change nothing.
  --include-journal     Vacuum systemd journal older than 30 days.
  --journal-age AGE     Journal retention when --include-journal is used.
  --no-optimise         Do not deduplicate the Nix store after garbage collection.
  -h, --help            Show this help.

Examples:
  scripts/clean-nixos.sh                 # review, then clean generations older than 90d
  scripts/clean-nixos.sh --age 30d --yes
  scripts/clean-nixos.sh --dry-run
EOF
}

while (($#)); do
  case "$1" in
    --age) AGE=${2:?--age needs a value}; shift 2 ;;
    --yes) ASSUME_YES=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --include-journal) INCLUDE_JOURNAL=1; shift ;;
    --journal-age) JOURNAL_AGE=${2:?--journal-age needs a value}; shift 2 ;;
    --no-optimise) OPTIMISE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ $EUID -eq 0 ]]; then
  SUDO=()
else
  SUDO=(sudo)
fi

bytes_used() {
  df -B1 --output=used / | awk 'NR == 2 { print $1 }'
}

store_bytes() {
  du -sx --bytes /nix/store 2>/dev/null | awk '{ print $1 }'
}

format_bytes() {
  numfmt --to=iec --suffix=B "$1"
}

ROOT_USED=0
STORE_USED=0
print_report() {
  local label=$1
  ROOT_USED=$(bytes_used)
  STORE_USED=$(store_bytes || echo 0)
  printf '\n== %s ==\n' "$label"
  df -h / | tail -n 1
  printf 'Nix store: %s\n' "$(format_bytes "$STORE_USED")"
  printf 'Root filesystem used: %s\n' "$(format_bytes "$ROOT_USED")"
}

print_report "Before cleanup"
BEFORE_ROOT_USED=$ROOT_USED
BEFORE_STORE_USED=$STORE_USED
printf '\nSystem generations:\n'
"${SUDO[@]}" nix-env --profile /nix/var/nix/profiles/system --list-generations || true

printf '\nReclaimable store paths (this may take a moment):\n'
"${SUDO[@]}" nix-store --gc --print-dead | sed -n '1,80p'
if [[ $DRY_RUN -eq 1 ]]; then
  printf '\nDry run: no changes made.\n'
  exit 0
fi

if [[ $ASSUME_YES -ne 1 ]]; then
  printf '\nThis will remove system generations older than %s and unreachable store paths.\n' "$AGE"
  read -r -p 'Continue? [y/N] ' answer
  [[ $answer =~ ^[Yy]([Ee][Ss])?$ ]] || { echo 'Cancelled.'; exit 0; }
fi

printf '\nRemoving old system generations and collecting garbage...\n'
"${SUDO[@]}" nix-collect-garbage --delete-older-than "$AGE"

if [[ $OPTIMISE -eq 1 ]]; then
  printf '\nDeduplicating identical files in the Nix store...\n'
  if command -v nix >/dev/null 2>&1; then
    "${SUDO[@]}" nix store optimise
  else
    "${SUDO[@]}" nix-store --optimise
  fi
fi

if [[ $INCLUDE_JOURNAL -eq 1 ]] && command -v journalctl >/dev/null 2>&1; then
  printf '\nVacuuming systemd journal older than %s...\n' "$JOURNAL_AGE"
  "${SUDO[@]}" journalctl --vacuum-time="$JOURNAL_AGE"
fi

print_report "After cleanup"

ROOT_RECLAIMED=$((BEFORE_ROOT_USED - ROOT_USED))
STORE_RECLAIMED=$((BEFORE_STORE_USED - STORE_USED))
printf '\nReclaimed root filesystem space: %s\n' "$(format_bytes "$ROOT_RECLAIMED")"
printf 'Nix store size change: %s\n' "$(format_bytes "$STORE_RECLAIMED")"
printf '(A negative value means usage increased.)\n'
