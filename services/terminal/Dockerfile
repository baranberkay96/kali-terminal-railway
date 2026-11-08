# Kali Linux Web Terminal for Railway.
#
# Kali Linux (kali-rolling) with ttyd serving tmux sessions, behind an nginx
# basic-auth proxy. The shell runs as the non-root user "kali" (passwordless
# sudo), and /home is a Railway volume. The base image is pinned by digest:
# change it and redeploy to upgrade.
FROM kalilinux/kali-rolling:latest@sha256:6ec743d9fc5cd397451eeddeff3869bcfab5de9bd5dec5b1f34cbfbd80313073

# Extra Kali packages to bake into the image, space separated, for example
# "metasploit-framework" or "kali-linux-headless". Railway passes the service
# variable of the same name as a build argument, so changing it rebuilds the
# image with those packages. They survive redeploys, unlike `apt install` in
# the shell.
ARG KALI_EXTRA_PACKAGES=""

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8 \
    TZ=UTC

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# System packages: the auth proxy (nginx), the web terminal (ttyd), the init
# (tini), tmux and everyday shell tools. `apt-get full-upgrade` brings the
# rolling base up to date.
RUN apt-get update \
 && apt-get full-upgrade -y \
 && apt-get install -y --no-install-recommends \
      bash-completion build-essential ca-certificates curl fastfetch file git \
      htop iproute2 iputils-ping jq less lsof man-db nano ncurses-term \
      netcat-traditional nginx openssh-client openssl pipx procps python3-pip \
      python3-venv ripgrep socat sudo tini tmux tree ttyd tzdata unzip vim \
      wget zip \
 && rm -f /etc/nginx/sites-enabled/default \
 && rm -rf /var/lib/apt/lists/*

# Command-line security tools. Recon: nmap, masscan, dnsrecon, subfinder,
# httpx, whois, dig. Web: sqlmap, gobuster, ffuf, feroxbuster, dirb, whatweb,
# wfuzz, nuclei, sslscan. Passwords: hydra, john, wordlists (rockyou).
# Windows/AD: smbclient, enum4linux-ng, netexec, impacket. Reference:
# searchsploit (exploitdb). GUI tools are left out: this is a terminal.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bind9-dnsutils dirb dnsrecon enum4linux-ng exploitdb feroxbuster ffuf \
      gobuster httpx-toolkit hydra impacket-scripts john kali-linux-core \
      masscan netexec nmap nuclei smbclient sqlmap sslscan subfinder \
      theharvester whatweb wfuzz whois wordlists \
 && rm -rf /var/lib/apt/lists/*

# Optional extras from KALI_EXTRA_PACKAGES, checked as package names first so
# the variable cannot inject shell or apt options.
RUN set -eux; \
    read -r -a extra <<< "${KALI_EXTRA_PACKAGES//,/ }"; \
    if (( ${#extra[@]} > 0 )); then \
      for pkg in "${extra[@]}"; do \
        [[ "$pkg" =~ ^[a-z0-9][a-z0-9+.-]+$ ]] || { echo "KALI_EXTRA_PACKAGES: invalid package name '${pkg:0:64}'" >&2; exit 1; }; \
      done; \
      apt-get update; \
      apt-get install -y --no-install-recommends "${extra[@]}"; \
      rm -rf /var/lib/apt/lists/*; \
    fi

# The login user. It has a fixed uid 1000 so file ownership on the volume stays
# stable across image updates. New homes get Kali's default dotfiles plus one
# line that loads this template's shell defaults.
RUN set -eux; \
    printf '\n# Kali Web Terminal defaults (prompt, history, PATH). Delete these lines to opt out.\nif [ -r /etc/kali-terminal/bashrc ]; then . /etc/kali-terminal/bashrc; fi\n' \
      >> /etc/skel/.bashrc; \
    useradd --create-home --uid 1000 --user-group --groups sudo --shell /bin/bash kali; \
    printf 'kali ALL=(ALL:ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/90-kali-terminal; \
    chmod 0440 /etc/sudoers.d/90-kali-terminal; \
    visudo -cf /etc/sudoers.d/90-kali-terminal

COPY entrypoint.sh /usr/local/bin/kali-terminal-entrypoint
COPY terminal-session.sh /usr/local/bin/terminal-session
COPY bashrc.sh /etc/kali-terminal/bashrc
COPY motd.txt /etc/kali-terminal/motd
COPY nginx.conf.template /etc/kali-terminal/nginx.conf.template
COPY tmux.conf /etc/tmux.conf
RUN chmod 0755 /usr/local/bin/kali-terminal-entrypoint /usr/local/bin/terminal-session \
 && chmod 0644 /etc/kali-terminal/bashrc /etc/kali-terminal/motd \
      /etc/kali-terminal/nginx.conf.template /etc/tmux.conf

EXPOSE 8080

# On Railway, podman-init is PID 1 and this runs under it. tini -s registers as
# a child subreaper, so orphaned processes (the tmux server, background jobs)
# are reaped whether or not tini is PID 1.
ENTRYPOINT ["/usr/bin/tini", "-s", "--", "/usr/local/bin/kali-terminal-entrypoint"]
