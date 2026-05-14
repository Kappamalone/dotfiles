#!/usr/bin/env bash

# Symlink dotfiles from this repo into $HOME.
# - Always verbose
# - Never overwrites (skips if destination exists)
# - Skips from a preconfigured list
# - Special handling for .config:
#     Always MERGE: ensures ~/.config exists and links each entry inside .config
#

set -euo pipefail
git config user.name "Kappamalone"
git config user.email "uzman.zawahir1@gmail.com"

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

  # Special handling for .config at repo root: always MERGE into ~/.config
  if [[ "$name" == "config" ]]; then
    handle_config_dir "$src"
    return
  fi


  if [[ "$name" != .* ]]; then
    echo "⏭️  Skipping $name (not a dotfile)"
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

# DEPENDENCIES:
#
# Install only if NOT already on PATH.

USR_BIN="$HOME/usr/bin"
mkdir -p "$USR_BIN"
# Prepend so a freshly installed tool is usable in this run;
# does NOT force install if a system one already exists.
export PATH="$USR_BIN:$PATH"

on_path() { command -v "$1" >/dev/null 2>&1; }
is_elf()   { file -b "$1" 2>/dev/null | grep -q '^ELF'; }

install_tmux_if_missing() {
  if on_path tmux; then
    echo "✅ tmux already on PATH at: $(command -v tmux)"
    return 0
  fi

  echo "⬇️  Installing tmux (AppImage) into $USR_BIN ..."
  tmp="$(mktemp)"
  if curl -fsSL \
      "https://github.com/nelsonenzo/tmux-appimage/releases/latest/download/tmux.appimage" \
      -o "$tmp"; then
    if is_elf "$tmp"; then
      install -m 0755 "$tmp" "$USR_BIN/tmux"
      echo "✅ tmux installed → $USR_BIN/tmux"
    else
      echo "❌ Downloaded tmux file is not an ELF binary (likely a 404 HTML). Skipping."
    fi
  else
    echo "❌ Failed to download tmux AppImage. Skipping."
  fi
  rm -f "$tmp"
}

install_rg_if_missing() {
  if on_path rg; then
    echo "✅ rg already on PATH at: $(command -v rg)"
    return 0
  fi

  echo "⬇️  Installing ripgrep (static musl) into $USR_BIN ..."
  tmpd="$(mktemp -d)"
  if curl -fsSL \
      "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz" \
      -o "$tmpd/rg.tgz"; then
    tar -xzf "$tmpd/rg.tgz" -C "$tmpd"
    rgpath="$(find "$tmpd" -type f -name rg -perm -u+x | head -n1 || true)"
    if [[ -n "$rgpath" ]] && is_elf "$rgpath"; then
      install -m 0755 "$rgpath" "$USR_BIN/rg"
      echo "✅ rg installed → $USR_BIN/rg"
    else
      echo "❌ Could not locate a valid rg binary after extraction. Skipping."
    fi
  else
    echo "❌ Failed to download ripgrep. Skipping."
  fi
  rm -rf "$tmpd"
}

install_tmux_if_missing
install_rg_if_missing

install_personal_sh() {
  local source_line="source \"$DOTFILES_DIR/personal.sh\""
  local marker="# >>> dotfiles personal.sh >>>"
  local found_rc=0

  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$rc" ]] || continue
    found_rc=1
    if grep -Fq "$marker" "$rc"; then
      echo "✅ personal.sh already sourced in $rc"
      continue
    fi
    printf '\n%s\n%s\n' "$marker" "$source_line" >> "$rc"
    echo "✅ Appended personal.sh source to $rc"
  done

  if [[ "$found_rc" -eq 0 ]]; then
    echo "ℹ️  No ~/.bashrc or ~/.zshrc found — add manually:"
    echo "    $source_line"
  fi

}

install_scripting_tools() {
  echo "🔧 Installing personal CLI tools into $USR_BIN ..."

  # List of scripts (relative to repo root)
  declare -a PERSONAL_BIN=(
    "fuzz.sh"
  )

  local src name dst
  for src in "${PERSONAL_BIN[@]}"; do
    name="$(basename "$src" .sh)"   # strip .sh → "fuzz"
    src_path="$DOTFILES_DIR/$src"
    dst="$USR_BIN/$name"

    if [[ ! -f "$src_path" ]]; then
      echo "⚠️  Missing: $src_path"
      continue
    fi

    # Link (not copy) so updates to dotfiles are immediate
    ln -sf "$src_path" "$dst"
    chmod +x "$src_path"

    echo "✅ Installed $name → $dst"
  done
}

install_personal_sh
install_scripting_tools
