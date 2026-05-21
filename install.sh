#!/usr/bin/env bash

gresource_path="/usr/share/gnome-shell/gnome-shell-theme.gresource"

function _check_requirements() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
    if [[ -z "$XDG_CURRENT_DESKTOP" || "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
        echo "This script is intended for GNOME desktop environments. Exiting."
        exit 1
    else
        echo "GNOME desktop environment detected. Proceeding with installation."
    fi
}

function _backup_gresource() {
    if [[ -f $gresource_path.bak ]]; then
        echo "Backup already exists and is up to date. Skipping backup."
        return
    fi
    echo "Backing up gnome-shell-theme.gresource to gnome-shell-theme.gresource.bak"
    cp $gresource_path $gresource_path.bak
}

function _restore_gresource() {
    if [[ -f $gresource_path.bak ]]; then
        echo "Restoring gnome-shell-theme.gresource from backup"
        mv $gresource_path.bak $gresource_path
    else
        echo "No backup found. Cannot restore gnome-shell-theme.gresource."
    fi
}

function _install_theme() {
    local theme_dir="gnome-shell"

    if [[ ! -f $theme_dir/gnome-shell-theme.gresource.xml ]]; then
        echo "Error: gnome-shell-theme.gresource.xml not found in the current directory."
        return
    fi

    echo "Compiling gnome-shell-theme.gresource.xml to $gresource_path"
    glib-compile-resources $theme_dir/gnome-shell-theme.gresource.xml --target=$gresource_path --sourcedir=$theme_dir
}

function _main() {
    if [[ "$1" == "restore" ]]; then
        _restore_gresource
        exit 0
    fi
    _check_requirements
    _backup_gresource
    _install_theme
    echo "Installation complete."
    echo "Logout for changes to take effect."
}

_main "$@"
