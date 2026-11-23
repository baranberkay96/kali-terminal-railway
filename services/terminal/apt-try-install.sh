#!/usr/bin/env bash
# apt-try-install PKG...: installs optional packages at build time without
# ever failing the build. kali-rolling changes daily: a package can be
# uninstallable for a few days during a library transition, or a mirror can
# be mid-sync. One such package must not fail every user's deploy, so the
# whole list is tried first, then each package alone. Packages that still
# fail are skipped with a warning and listed in
# /etc/kali-terminal/skipped-packages, which the entrypoint reports in the
# deploy log.
set -uo pipefail

readonly SKIPPED="/etc/kali-terminal/skipped-packages"

install -d -m 0755 /etc/kali-terminal
touch "$SKIPPED"

(( $# > 0 )) || exit 0

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

if apt_install "$@"; then
  exit 0
fi

echo "WARNING: installing '$*' together failed. Trying one package at a time." >&2
dpkg --configure -a || true
DEBIAN_FRONTEND=noninteractive apt-get install -f -y || true
for pkg in "$@"; do
  if ! apt_install "$pkg"; then
    echo "WARNING: skipping '${pkg}', apt could not install it." >&2
    printf '%s\n' "$pkg" >> "$SKIPPED"
    dpkg --configure -a || true
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y || true
  fi
done
exit 0
