# NOTICE: Kali Linux Web Terminal template

## Software installed in the image

| Component | Source | License | How it is used |
|---|---|---|---|
| Kali Linux (kali-rolling) | `kalilinux/kali-rolling` (official image), https://hub.docker.com/r/kalilinux/kali-rolling, pinned by digest `sha256:6ec743d9…` (2026-11-08) | Various free licenses (see `/usr/share/doc/*/copyright` in the image) | Base image (`FROM`) and apt packages |
| ttyd 1.7.7 | Kali package `ttyd` (1.7.7-8) | MIT, Copyright (c) 2016-2022 Shuanglei Tao | Web terminal on loopback, installed unmodified |
| nginx 1.30 | Kali package `nginx` | BSD-2-Clause | Basic-auth reverse proxy. The config was written for this template |
| tmux 3.7 | Kali package `tmux` | ISC | Persistent sessions |
| tini 0.19.0 | Kali package `tini` | MIT | Init and child subreaper |
| nmap, sqlmap, ffuf, gobuster, feroxbuster, dirb, whatweb, wfuzz, nuclei, subfinder, httpx-toolkit, dnsrecon, theHarvester, sslscan, hydra, john, wordlists, netexec, impacket-scripts, smbclient, enum4linux-ng, exploitdb, kali-linux-core and the everyday CLI tools | Kali packages | Each package's own license (nmap: Nmap Public Source License; others GPL, MIT, BSD and similar) | Installed unmodified from the Kali archive |

Changes to installed Kali files: file capabilities are removed from all binaries (Railway's containers cannot exec binaries whose capabilities they lack), Kali's `/usr/bin/nmap` wrapper is diverted with `dpkg-divert` to a symlink to `/usr/lib/nmap/nmap` and `/etc/profile.d/zz-kali-terminal-nmap.sh` unsets the `NMAP_PRIVILEGED` that Kali's `/etc/profile.d/nmap.sh` sets, and Kali's login messages are turned off through `/etc/kali-motd/disable-all`. No package files are edited.

Optional packages named in `KALI_EXTRA_PACKAGES` are installed from the Kali archive at build time under their own licenses.

Product names belong to their owners. This is a community template, not affiliated with OffSec, the Kali Linux project, the ttyd author or Railway. "Kali Linux" is a trademark of OffSec Services Limited.

## Upstream files and data checked (2026-11-08)

- Docker Hub tags of `kalilinux/kali-rolling` (`latest`, multi-arch index `sha256:6ec743d9fc5c…`, updated 2026-11-08).
- Kali `kali-rolling` `InRelease` and `main/binary-amd64/Packages` index: every package name and version above, and the installed size of the default set (about 1.8 GB) and of `kali-linux-headless` (about 6 GB), computed from `Depends`/`Pre-Depends`. `base-files` 2026.3.1 gives the 2026.3 version label. `nikto` is not in `main` and is not installed.
- The ttyd behaviour this template relies on (auth-header mode `-H`, loopback `-i lo`, the `-c` startup log line that prints the credential) was checked for the Debian Web Terminal template of the same author against ttyd tag `1.7.7`; Kali ships the same release.

## Market templates and repositories reviewed

| Template / repo | License | Use |
|---|---|---|
| `kali-linux-web-terminal` "Kali Linux (Web Terminal)" / `decoge/kali-linux-webterminal-railway` | not checked | Template config and README read for feature expectations (kali-rolling, ttyd, USERNAME/PASSWORD, `/data` volume). Nothing copied |
| `kali-linux-terminal`, `E7oTLJ` (Kali Linux) | n/a | Listing text read for feature expectations. Nothing copied |

All files in this package were written for this template, adapted from the same author's Debian 13 Web Terminal template: the Dockerfile, `entrypoint.sh`, `terminal-session.sh`, `bashrc.sh`, `tmux.conf`, `nginx.conf.template`, `motd.txt` and the docs.
