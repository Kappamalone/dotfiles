#!/usr/bin/env bash
set -euo pipefail

# Canonical compile script (must exist)
ROOT="$(pwd)"
CANONICAL="$ROOT/compile.sh"

if [[ ! -f "$CANONICAL" ]]; then
  echo "Error: $CANONICAL does not exist"
  exit 1
fi

echo "Using canonical compile script:"
echo "  $CANONICAL"
echo

for dir in "$ROOT"/*; do
  # Only operate on directories
  [[ -d "$dir" ]] || continue

  TARGET="$dir/compile.sh"

  # Skip if this is the canonical location itself
  if [[ "$TARGET" -ef "$CANONICAL" ]]; then
    continue
  fi

  # If compile.sh already exists
  if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    # If it's already the correct symlink, do nothing
    if [[ -L "$TARGET" && "$(readlink -f "$TARGET")" == "$CANONICAL" ]]; then
      echo "✔ $dir already linked"
      continue
    fi

    echo "⚠ Skipping $dir (compile.sh already exists)"
    continue
  fi

  ln -s "$CANONICAL" "$TARGET"
  echo "→ Linked compile.sh into $dir"
done
