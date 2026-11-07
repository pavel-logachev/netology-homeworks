# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS lab
WORKDIR /lab
LABEL org.opencontainers.image.description="Disposable Netology 13-03 security lab, never expose to production"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends suricata suricata-update fail2ban openssh-server rsyslog iptables nftables nmap hydra iproute2 curl ca-certificates python3 procps && rm -rf /var/lib/apt/lists/*
RUN suricata-update --no-test --no-reload
COPY start-defender.sh /lab/start-defender.sh
COPY local.rules /lab/local.rules
COPY sshd_config /lab/sshd_config
COPY jail.local /lab/jail.local
COPY users.txt pass.txt /lab/
COPY *.py /lab/
# Root is intentional: packet capture, sshd, iptables and Fail2Ban are the subjects of this disposable lab.
EXPOSE 22
CMD ["sleep", "infinity"]
