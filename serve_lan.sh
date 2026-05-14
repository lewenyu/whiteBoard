#!/usr/bin/env bash
# 在局域网内通过 HTTP 提供本目录下的 whiteboard_bridge.html
#启动  执行脚本  cd /Users/lingshi/whiteBoard  ./serve_lan.sh

set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8080}"

pick_ip() {
  local ip
  # 优先 172.x.x.x（常见办公/访客网段），再退回网卡顺序与其它 IPv4
  ip=$(ifconfig 2>/dev/null | awk '/inet / && $2 ~ /^172\./ {print $2; exit}')
  if [[ -n "${ip:-}" ]]; then echo "$ip"; return; fi
  for iface in en0 en1; do
    ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
    if [[ -n "${ip:-}" ]]; then echo "$ip"; return; fi
  done
  ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
}

IP="$(pick_ip || true)"
echo "目录: $(pwd)"
echo "端口: $PORT"
echo "本机: http://127.0.0.1:$PORT/whiteboard_bridge.html"
if [[ -n "${IP:-}" ]]; then
  echo "局域网: http://$IP:$PORT/whiteboard_bridge.html"
else
  echo "（未能自动检测 IP，请在「系统设置 → 网络」查看本机地址）"
fi
echo "按 Ctrl+C 停止"
exec python3 -m http.server "$PORT" --bind 0.0.0.0
