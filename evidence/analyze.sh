#!/bin/sh
set -eu
cd /evidence/verified
S=172.24.0.3
T=172.24.0.2
count() {
 mode="$1"; label="$2"; filter="$3"
 printf '%s | %s | %s | ' "$mode.pcap" "$label" "$filter"
 tshark -r "$mode.pcap" -n -Y "$filter" -T fields -e frame.number 2>/dev/null | wc -l
}
{
 echo 'Counts from verified pcaps. tshark filters use #1 outer IPv4 occurrence to exclude scanner ICMP with quoted target IPv4.'
 count syn scanner_SYN "ip.src#1==$S && ip.dst#1==$T && tcp.flags==0x0002"
 count syn target_SYN_ACK "ip.src#1==$T && ip.dst#1==$S && tcp.flags==0x0012"
 count syn target_RST_ACK "ip.src#1==$T && ip.dst#1==$S && tcp.flags==0x0014"
 count syn scanner_RST "ip.src#1==$S && ip.dst#1==$T && tcp.flags.reset==1"
 count syn target_closed_65000 "ip.src#1==$T && tcp.srcport==65000 && tcp.flags.reset==1"
 for mode in fin xmas; do
  flag=0x0001; test "$mode" = xmas && flag=0x0029
  count "$mode" scanner_probes "ip.src#1==$S && ip.dst#1==$T && tcp.flags==$flag"
  count "$mode" probes_to_open "ip.src#1==$S && ip.dst#1==$T && tcp.flags==$flag && tcp.dstport!=65000"
  count "$mode" probes_to_closed "ip.src#1==$S && ip.dst#1==$T && tcp.flags==$flag && tcp.dstport==65000"
  count "$mode" target_replies_open "ip.src#1==$T && ip.dst#1==$S && tcp.srcport in {21 22 80 445}"
  count "$mode" target_closed_RST_ACK "ip.src#1==$T && ip.dst#1==$S && tcp.srcport==65000 && tcp.flags==0x0014"
 done
 count udp scanner_UDP "ip.src#1==$S && ip.dst#1==$T && udp && !icmp"
 count udp target_UDP "ip.src#1==$T && ip.dst#1==$S && udp && !icmp"
 count udp target_RPC_reply "ip.src#1==$T && ip.dst#1==$S && udp.srcport==111 && !icmp"
 count udp target_NBNS_reply "ip.src#1==$T && ip.dst#1==$S && udp.srcport==137 && !icmp"
 count udp target_ICMP_unreachable "ip.src#1==$T && ip.dst#1==$S && icmp.type==3 && icmp.code==3"
 for p in 53 161 65000; do
  count udp "closed_${p}_ICMP" "ip.src#1==$T && ip.dst#1==$S && icmp.type==3 && icmp.code==3 && udp.dstport==$p"
 done
 count udp TFTP_probes "ip.src#1==$S && ip.dst#1==$T && udp.dstport==69 && !icmp"
 count udp TFTP_replies "ip.src#1==$T && ip.dst#1==$S && (udp || icmp) && udp.srcport==69"
} > traffic-counts.txt
for mode in syn fin xmas udp; do
 tshark -r "$mode.pcap" -n -T fields -E header=y -E separator='|' -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags -e udp.srcport -e udp.dstport -e icmp.type -e icmp.code -e _ws.col.Info > "$mode-fields.txt" 2> "$mode-tshark-stderr.txt"
done
cat traffic-counts.txt
