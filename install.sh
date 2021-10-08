#!/usr/bin/env bash
set -e

# workaround to run scripts at any directory
script_dir="$(dirname "$0")"
script_dir="$(cd "$script_dir"; pwd)"

ignored_things=" install.sh tmux tpm README.md "

plugin_dir="$HOME/.tmux/plugins/"

init_submodules() {
    git submodule init
    git submodule update
}

compile_tmux() {
    if [[ -f "$script_dir/Makefile" ]]; then
        return
    fi

    sh autogen.sh;
    ./configure >/dev/null 2>&1
    make >/dev/null 2>&1;
}

install() {
    if which tmux; then
        echo "tmux already installed!"
        return
    fi

    printf "\033[1;32;49m=== Type Y/y to install tmux: \033[0m"
    read -n 1 c; echo '';
    if [[ !( " y Y " =~ " $c " ) ]]; then
        return
    fi

    create-symlinks

    (echo "Installing tmux..."; \
    cd "$script_dir"; \
    init_submodules; \
    compile_tmux; \
    sudo make install; \
    echo "tmux installed successfully!")
}

uninstall() {
    printf "\033[1;31;49m=== Do you want to uninstall tmux (Y/y)? \033[0m"
    read -n 1 c; echo ''
    if [[ !( " y Y " =~ " $c " ) ]]; then
        return
    fi

    remove-symlinks

    (echo "Uninstalling tmux..."; \
    cd "$script_dir"; \
    init_submodules; \
    compile_tmux; \
    sudo make uninstall; \
    echo "tmux installed successfully!")
}

create-symlinks() {
    echo "Creating symlinks in $HOME"
    for file in "$script_dir"/*; do
        name="$(basename "$file")"
        if [[ !( $ignored_things =~ " $name " ) ]]; then
            ln -sfv $file "$HOME/.$name"
        fi
    done

    mkdir -p "$plugin_dir"
    rm -rfv "$plugin_dir/*"
    ln -sfv "$script_dir/tpm" "$plugin_dir/tpm"
}

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

run_script() {
    while :
        do
        printf "\033[1;33;49mWhat do you want to do?\n(i)nstall\n(u)ninstall\n\033[0m"
        read -n 1 user_input; echo ''
        case $user_input in
            i|I)
                install
                break
                ;;
            u|U)
                uninstall
                break
                ;;
            *)
                echo "Invalid option!"
                ;;
        esac
    done
}

run_script