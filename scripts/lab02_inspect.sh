#!/usr/bin/env bash
# Extrae de los XML de host discovery el motivo exacto de cada "Host is up".
set -u
cd "$HOME/evidencias/lab02" || exit 1
for f in icmp_echo icmp_ts tcp_syn tcp_ack udp_ping arp_ping mixto loopback; do
  echo "===== $f ====="
  if [ -f "$f.xml" ]; then
    grep -E '<status ' "$f.xml" | sed 's/^ *//' | head -3
    grep -E '<times ' "$f.xml" | sed 's/^ *//' | head -2
    grep -E 'scanner=|<runstats>' "$f.xml" | sed 's/^ *//' | head -3
  else
    echo "(sin archivo)"
  fi
  echo
done
