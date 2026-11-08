# Deploy and Host Kali Linux 2026.3 Web Terminal with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/kali-linux-20263-web-terminal-browser-she?referralCode=20H68q)

A Kali Linux 2026.3 (kali-rolling) shell you open in any browser, with the command-line tools people reach for first: nmap, sqlmap, ffuf, gobuster, feroxbuster, nuclei, hydra, john, netexec, impacket and searchsploit. The shell runs in tmux, so sessions and long scans survive closed tabs. A generated password protects it, and your home directory sits on a persistent volume. Need Metasploit or the full Kali tool set? Name it in one variable and Railway bakes it into the image.

## About Hosting Kali Linux 2026.3 Web Terminal

A web terminal needs a long-running Linux container, a terminal server, real authentication in front of it, TLS, and storage that outlives rebuilds. This community template builds on the official `kalilinux/kali-rolling` image (pinned by digest) and serves the shell with ttyd. nginx stands in front of ttyd and checks a password that Railway generates at deploy, so the login never shows up in logs. You work as the user `kali` with sudo, and `/home` is a Railway volume. Railway's edge provides HTTPS.

## Common Use Cases

- Security training, CTFs and HackTheBox / TryHackMe style labs from any browser, including Chromebooks and managed work laptops
- Recon and web testing of systems you own or are authorized to test, from a cloud IP instead of your home connection
- Running long scans and brute-force jobs in tmux and checking back on them later
- Learning Kali's command-line tools without installing a VM

## Dependencies for Kali Linux 2026.3 Web Terminal Hosting

- A Railway volume mounted at `/home` (included in the template)
- Nothing else: no database, no API keys, no external accounts

### Deployment Dependencies

- Kali Linux documentation: https://www.kali.org/docs/
- Kali Docker images: https://www.kali.org/docs/containers/official-kalilinux-docker-images/
- Kali tool metapackages: https://www.kali.org/docs/general-use/metapackages/
- ttyd (web terminal, MIT): https://github.com/tsl0922/ttyd
- tmux: https://github.com/tmux/tmux/wiki
- Railway build variables: https://docs.railway.com/builds/dockerfiles#using-variables-at-build-time
- Railway Fair Use Policy: https://railway.com/legal/fair-use

### Implementation Details

| Service | Source | Purpose |
|---|---|---|
| Terminal | Dockerfile based on `kalilinux/kali-rolling` | nginx basic-auth proxy on port 8080 (public HTTPS domain, `/healthz`), ttyd on loopback, tmux sessions, user `kali` with sudo, volume at `/home` |

**Plan:** PLAN_LINE

**First login**

1. Open the service's public URL.
2. Your browser asks for a user name and password. The user name is `kali` (the `USERNAME` variable). The password is the generated `PASSWORD` value on the service's Variables tab.
3. You land in a tmux session named `main`. Close the tab at any time and reopen the URL to resume. For a second, independent session, open `https://{your-domain}/?arg=work`.
4. `sudo -i` gives you a root shell.

**Tools included**

| Area | Tools |
|---|---|
| Recon | nmap, dnsrecon, subfinder, httpx (`httpx-toolkit`), theHarvester, whois, dig |
| Web | sqlmap, ffuf, gobuster, feroxbuster, dirb, whatweb, wfuzz, nuclei, sslscan |
| Passwords | hydra, john, `/usr/share/wordlists` (rockyou and others) |
| Windows / AD | netexec, impacket scripts, smbclient, enum4linux-ng |
| Reference | searchsploit (exploitdb) |
| Everyday | git, curl, wget, python3, pip, pipx, build-essential, vim, nano, tmux, htop, jq, socat |

**More tools**: set the `KALI_EXTRA_PACKAGES` variable to a space-separated list of Kali packages, for example `metasploit-framework` or `kali-linux-headless` (Kali's full command-line set). Railway passes the variable to the Docker build, so the next deploy builds an image with those packages and they survive every redeploy. Larger sets make the image bigger and the build slower. Packages you install with `sudo apt install` in the shell work right away but reset on the next redeploy.

**What persists**: everything under `/home/kali`: files, loot, notes, shell history, Python virtualenvs and pipx apps in `~/.local`, Go tools in `~/go/bin`. Running processes and packages installed with apt reset on every redeploy or restart. tmux keeps sessions alive across browser reconnects, not across container restarts.

**Authorized use only**

Kali's tools can scan, brute-force and exploit systems. Use them only against systems you own or have written permission to test. Railway's [Fair Use Policy](https://railway.com/legal/fair-use) and [Terms of Service](https://railway.com/legal/terms) apply to everything that runs in this shell, and scanning or attacking third-party networks from Railway can get your account suspended. NETWORK_LINE

**Security**: the shell is never served without a password. With an empty or short `PASSWORD` the service refuses to start. nginx checks the password, which the container keeps only as a SHA-512 crypt hash, and rate-limits attempts. It also rejects WebSocket connections from other sites. ttyd listens on 127.0.0.1 only. The password does not appear in logs, process arguments or the shell environment. To change it, edit `PASSWORD` and redeploy. Browsers cache basic-auth logins until you close them, so use a private window on shared computers.

**Scaling**: this is a single-user machine on one volume, so keep one replica. Railway scales RAM and CPU vertically up to your plan limit. For a team, deploy one terminal per person.

**Pinning and upgrades**: the Kali base image is pinned by digest on the `FROM` line of `services/terminal/Dockerfile`. Every fresh build runs `apt-get full-upgrade`, which brings the rolling release up to date. Railway may reuse cached build layers, so change the digest to force a fresh one.

### Why Deploy Kali Linux 2026.3 Web Terminal on Railway?

Railway gives the terminal an HTTPS URL, a persistent volume and automatic restarts, with no server to administer. You get a protected Kali shell from one click and pay only for the CPU and memory it uses. This is a community template, not affiliated with OffSec, the Kali Linux project, the ttyd author or Railway. Kali Linux is a trademark of OffSec Services Limited.
