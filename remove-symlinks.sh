#!/usr/bin/env bash
set -e

# workaround to run scripts at any directory
script_dir="$(dirname "$0")"
script_dir="$(cd "$script_dir"; pwd)"

plugin_dir="$HOME/.tmux/plugins"

ignored_things=" install.sh remove-symlinks.sh tmux tpm README.md "

remove-symlinks() {
    echo "Removing symlinks in $HOME"
    for file in "$script_dir"/*; do
        name="$(basename "$file")"
        if [[ !( $ignored_things =~ " $name " ) ]]; then
            rm -rfv "$HOME/.$name"
        fi
    done

    rm -rfv "$plugin_dir"
}

remove-symlinks