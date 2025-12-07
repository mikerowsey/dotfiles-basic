#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

backup_file() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "$target.bak"
    fi
}

link_file() {
    local src="$1"
    local dst="$2"

    # Only link if the source file actually exists
    if [ -f "$src" ]; then
        backup_file "$dst"
        ln -sf "$src" "$dst" || true
    fi
}

link_file "$DOTFILES_DIR/.vimrc"      "$HOME/.vimrc"
link_file "$DOTFILES_DIR/.bashrc"     "$HOME/.bashrc"
link_file "$DOTFILES_DIR/.gitconfig"  "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.tmux.conf"  "$HOME/.tmux.conf"

echo "Dotfiles installed for user: $USER in $HOME"
exit 0
