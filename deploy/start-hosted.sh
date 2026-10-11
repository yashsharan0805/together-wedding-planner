#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?Set the Neon database URL in the deployment environment}"
: "${SECRET_KEY_BASE:?Set a stable session secret in the deployment environment}"
: "${GOOGLE_CLIENT_ID:?Set the Google OAuth web client ID}"
: "${APPLICATION_HOST:?Set the stable production hostname without https://}"
export PORT="${PORT:-8080}"
export RAILS_PORT="${RAILS_PORT:-3000}"
[[ "$PORT" =~ ^[0-9]+$ && "$RAILS_PORT" =~ ^[0-9]+$ ]] || exit 1
# Replace only our two port placeholders, leaving Nginx variables intact.
sed -e "s/__PORT__/$PORT/g" -e "s/__RAILS_PORT__/$RAILS_PORT/g" \
  /app/nginx.conf.template > /app/nginx.conf
mkdir -p /rails/tmp/pids /rails/log
rm -f /rails/tmp/pids/server.pid
cleanup() {
  trap - TERM INT EXIT
  kill -TERM "${rails_pid:-}" "${nginx_pid:-}" 2>/dev/null || true
  wait || true
}
trap cleanup TERM INT EXIT
PORT="$RAILS_PORT" bundle exec puma -C config/puma.rb &
rails_pid=$!
for attempt in $(seq 1 60); do
  if curl --silent --fail "http://127.0.0.1:$RAILS_PORT/up" > /dev/null; then break; fi
  kill -0 "$rails_pid" 2>/dev/null || { wait "$rails_pid"; exit 1; }
  [[ "$attempt" == 60 ]] && { echo 'Rails startup timed out' >&2; exit 1; }
  sleep 0.5
done
nginx -c /app/nginx.conf -g 'daemon off;' &
nginx_pid=$!
wait -n "$rails_pid" "$nginx_pid"
