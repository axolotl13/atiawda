#!/usr/bin/env bash

gresource_path="/usr/share/gnome-shell/gnome-shell-theme.gresource"
theme_dir="gnome-shell"

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
    if [[ ! -f $theme_dir/gnome-shell-theme.gresource.xml ]]; then
        echo "Error: gnome-shell-theme.gresource.xml not found in the current directory."
        return
    fi

    echo "Compiling gnome-shell-theme.gresource.xml to $gresource_path"
    glib-compile-resources $theme_dir/gnome-shell-theme.gresource.xml --target=$gresource_path --sourcedir=$theme_dir
}

function _bubble() {
    echo "Bubble"
    # light
    sed -i '1803s/background-color: st-mix(-st-accent-color, #ffffff, 10%);/background-color: transparent;/' $theme_dir/gnome-shell-light.css
    sed -i '1811s/background-color: transparent;/background-color: st-mix(-st-accent-color, #ffffff, 10%);/' $theme_dir/gnome-shell-light.css
    # dark
    sed -i '1803s/background-color: st-mix(-st-accent-color, #0f0f0f, 10%);/background-color: transparent;/' $theme_dir/gnome-shell-dark.css
    sed -i '1810s/background-color: transparent;/background-color: st-mix(-st-accent-color, #0f0f0f, 10%);/' $theme_dir/gnome-shell-dark.css
}

function _main() {
    if [[ "$1" == "restore" ]]; then
        _restore_gresource
        exit 0
    fi
    _check_requirements
    if [[ "$1" == "bubble" ]]; then
        _bubble
    fi
    _backup_gresource
    _install_theme
    echo "Installation complete."
    echo "Logout for changes to take effect."
}

_main "$@"
