#!/usr/bin/env bash
# Band and anti-lag control for the active NetworkManager Wi-Fi connection (used by Settings → Wi-Fi band).
#   wifi-band.sh status              key=value lines describing the current link
#   wifi-band.sh band 5|2.4|auto     restrict the connection to a band (reconnects)
#   wifi-band.sh antilag on|off      lock to / unlock from the current access point (reconnects)
# Locking the BSSID stops roaming between bands, and NetworkManager doesn't background-scan a locked connection.
set -euo pipefail

dev=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')
[ -n "$dev" ] || { echo "error=No connected Wi-Fi"; exit 1; }
conn=$(nmcli -g GENERAL.CONNECTION device show "$dev")

get() { nmcli -g "802-11-wireless.$1" connection show "$conn" | tr -d '\\'; }
current_bssid() { iw dev "$dev" link | awk '/Connected to/ { print toupper($3) }'; }

case "${1:-status}" in
status)
    link=$(iw dev "$dev" link)
    echo "connection=$conn"
    echo "bssid=$(current_bssid)"
    echo "freq=$(awk '/freq:/ { print int($2) }' <<<"$link")"
    echo "signal=$(awk '/signal:/ { print $2 }' <<<"$link")"
    echo "band=$(get band)"
    echo "locked=$(get bssid)"
    echo "gateway=$(ip route show default dev "$dev" | awk '{ print $3; exit }')"
    ;;
band)
    case "${2:-}" in 5) want=a ;; 2.4) want=bg ;; auto) want="" ;; *) echo "error=Unknown band"; exit 2 ;; esac
    old=$(get band)
    locked=$(get bssid)
    nmcli connection modify "$conn" 802-11-wireless.band "$want" 802-11-wireless.bssid ""
    if ! nmcli connection up "$conn" >/dev/null 2>&1; then
        # Don't leave the user offline: go back to what worked
        nmcli connection modify "$conn" 802-11-wireless.band "$old" 802-11-wireless.bssid "$locked"
        nmcli connection up "$conn" >/dev/null 2>&1 || true
        echo "error=That band isn't reachable from here; switched back"
        exit 1
    fi
    # Keep anti-lag on across a band switch by re-locking to the access point we landed on
    if [ -n "$locked" ]; then
        nmcli connection modify "$conn" 802-11-wireless.bssid "$(current_bssid)"
        nmcli connection up "$conn" >/dev/null 2>&1
    fi
    ;;
antilag)
    case "${2:-}" in
    on) nmcli connection modify "$conn" 802-11-wireless.bssid "$(current_bssid)" ;;
    off) nmcli connection modify "$conn" 802-11-wireless.bssid "" ;;
    *) echo "error=Use on or off"; exit 2 ;;
    esac
    nmcli connection up "$conn" >/dev/null 2>&1
    ;;
*)
    echo "error=Unknown command"
    exit 2
    ;;
esac
