#!/usr/bin/env bash
# apt-update: `apt-get update` that survives kali-rolling mirror hiccups.
#
# The Kali archive has no by-hash index files, so a mirror that is mid-sync
# serves an InRelease that does not match its Packages files ("File has
# unexpected size", "Hash Sum mismatch"), and `apt-get update` fails. Every
# deploy of this template builds the image, and a failed build counts against
# the template's health, so the update is retried with a pause in between.
# The first attempts use Kali's official CDN (kali.download, set up in the
# Dockerfile); the last ones go through the http.kali.org redirector, which
# picks a different mirror.
set -uo pipefail

readonly ATTEMPTS=6
readonly FALLBACK_FROM=4
readonly CDN="http://kali.download/kali"
readonly REDIRECTOR="http://http.kali.org/kali"

use_mirror() {
  local from="$1" to="$2" file
  for file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [[ -f "$file" ]] && sed -i "s|${from}|${to}|g" "$file"
  done
}

for attempt in $(seq 1 "$ATTEMPTS"); do
  if (( attempt == FALLBACK_FROM )); then
    echo "WARNING: apt-get update failed $((attempt - 1)) times on ${CDN}; trying ${REDIRECTOR}." >&2
    use_mirror "$CDN" "$REDIRECTOR"
  fi
  if apt-get update; then
    (( attempt >= FALLBACK_FROM )) && use_mirror "$REDIRECTOR" "$CDN"
    exit 0
  fi
  echo "WARNING: apt-get update failed (attempt ${attempt}/${ATTEMPTS}); retrying in $((attempt * 10)) s." >&2
  rm -rf /var/lib/apt/lists/partial/*
  sleep $((attempt * 10))
done

use_mirror "$REDIRECTOR" "$CDN"
echo "ERROR: apt-get update failed ${ATTEMPTS} times; the Kali mirrors are unreachable or mid-sync. Redeploy in a few minutes." >&2
exit 1
