#!/bin/bash

set -eo pipefail

path="$1"

if [[ ! -d "$path" ]]; then
    echo "::error ::Invalid path: [$path]"
    exit 1
fi

outputwarning() {
    local warnings="$1"
    if [[ -n "$warnings" ]]; then
        warnings="${warnings//'%'/'%25'}"
        warnings="${warnings//$'\n'/'%0A'}"
        warnings="${warnings//$'\r'/'%0D'}"
        echo "::warning::$warnings"
    fi
}

abspath="$(realpath "$path")"

HOME=/home/build
echo "::group::Move files to $HOME"
cd "$HOME"
cp -r "$abspath" .
cd "$(basename "$abspath")"
echo "::endgroup::"

echo "::group::Source PKGBUILD"
source PKGBUILD
echo "::endgroup::"

echo "::group::Install depends"
paru -Syu --removemake --needed --noconfirm "${depends[@]}" "${makedepends[@]}"
echo "::endgroup::"

echo "::group::Remove paru and git"
sudo pacman -Rns --noconfirm paru-bin git || true
echo "::endgroup::"

echo "::group::List all installed packages"
pacman -Q
echo "::endgroup::"

echo "::group::Make the package"
logfile=$(mktemp)
makepkg -s --noconfirm 2>"$logfile"
outputwarning "$(grep WARN "$logfile" || true)"
source /etc/makepkg.conf # get PKGEXT
files=("${pkgname}-"*"${PKGEXT}")
pkgfile="${files[0]}"
echo "::set-output name=pkgfile::${pkgfile}"
echo "::endgroup::"

echo "::group::Run namcap checks"
sudo pacman -S --needed --noconfirm namcap
outputwarning "$(namcap PKGBUILD)"
outputwarning "$(namcap "${pkgfile}")"
echo "::endgroup::"

echo "::group::Show package info"
pacman -Qip "${pkgfile}"
pacman -Qlp "${pkgfile}"
echo "::endgroup::"

sudo mv "$pkgfile" /github/workspace

echo "::group::Generate .SRCINFO"
makepkg --printsrcinfo > .SRCINFO
sudo mv .SRCINFO "$abspath"
echo "::endgroup::"