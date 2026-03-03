#!/usr/bin/env bash
# Symlink dotfiles from this repo into $HOME.
# - Always verbose
# - Never overwrites (skips if destination exists)
# - Skips from a preconfigured list
# - Special handling for .config:
#     Always MERGE: ensures ~/.config exists and links each entry inside .config

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"
echo

declare -a SKIP_NAMES=(
  "."
  ".."
  ".git"
  "install.sh"
  "personal.sh"
)

should_skip_root() {
  local name="$1"
  for s in "${SKIP_NAMES[@]}"; do
    [[ "$name" == "$s" ]] && return 0
  done
  return 1
}

exists_any() {
  local p="$1"
  [[ -e "$p" || -L "$p" ]]
}

link_one_to_home() {
  local src="$1"
  local name dst
  name="$(basename "$src")"
  dst="$HOME/$name"

  if should_skip_root "$name"; then
    echo "⏭️  Skipping $name (skip list)"
    return
  fi

  if [[ "$name" != .* ]]; then
    echo "⏭️  Skipping $name (not a dotfile)"
    return
  fi

  # Special handling for .config at repo root: always MERGE into ~/.config
  if [[ "$name" == ".config" ]]; then
    handle_config_dir "$src"
    return
  fi

  if exists_any "$dst"; then
    echo "⚠️  Exists, not linking: $dst"
    return
  fi

  ln -s "$src" "$dst"
  echo "✅ Linked $name → $dst"
}

handle_config_dir() {
  local config_src="$1"
  local config_dst="${XDG_CONFIG_HOME:-$HOME/.config}"

  # If ~/.config is a symlink, don't try to merge into it.
  if [[ -L "$config_dst" ]]; then
    echo "⚠️  $config_dst is a symlink, not merging into it"
    return
  fi

  # Create ~/.config if missing (but don't overwrite files)
  if [[ ! -d "$config_dst" ]]; then
    if exists_any "$config_dst"; then
      echo "⚠️  $config_dst exists but is not a directory, not touching"
      return
    fi
    mkdir -p "$config_dst"
    echo "📁 Created directory: $config_dst"
  fi

  shopt -s dotglob nullglob
  local item name dst
  for item in "$config_src"/*; do
    name="$(basename "$item")"
    dst="$config_dst/$name"
    if exists_any "$dst" ; then
      echo "⚠️  $config_dst/$name exists, skipping"
      continue
    fi
    ln -s "$item" "$dst"
    echo "✅ Linked .config/$name → $dst"
  done
}

# Iterate over repo root entries (including dotfiles)
shopt -s dotglob nullglob
for item in "$DOTFILES_DIR"/*; do
  link_one_to_home "$item"
done

git config user.name "Kappamalone"
git config user.email "uzman.zawahir1@gmail.com"
