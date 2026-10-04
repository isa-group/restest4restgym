#!/bin/sh
#
# What RESTgym starts, and the one file here that knows anything about RESTgym's conventions.
#
# It must never exit. The platform stops this container when the time budget is up, and
# treats a container that ended on its own as a failed run - so the loop is not decoration.

set -u

API="${API:?the benchmark did not say which API this run is about}"
HOST="${HOST:-localhost}"
PORT="${PORT:-9090}"
TIME_BUDGET="${TIME_BUDGET:-60}"

# The platform mounts every API's document read-only under /specifications, in two shapes:
# the YAML one each API project publishes, and a JSON conversion of it. Prefer the original.
specification="/specifications/${API}.yaml"
if [ ! -f "$specification" ]; then
  specification="/specifications/${API}-openapi.json"
fi

url="http://${HOST}:${PORT}"

# What RESTest is handed besides the document: whatever config/ holds - a plan, passed to every
# API, a file of settings, also passed to every API, and a dictionary per API, passed to that API
# alone. An empty config/ is RESTest with its published defaults.
told=""
if [ -f /tool/config/plan.yaml ]; then
  told="${told} --campaign /tool/config/plan.yaml"
fi
if [ -f /tool/config/settings.yaml ]; then
  told="${told} --settings /tool/config/settings.yaml"
fi
if [ -d "/tool/config/dictionaries/${API}" ]; then
  told="${told} --dictionary /tool/config/dictionaries/${API}/"
fi

echo "RESTest against ${API} at ${url}"
echo "  document:    ${specification}"
echo "  time budget: ${TIME_BUDGET} minutes"
echo "  built from:  $(cat /tool/dist/restest-ref.txt)"
echo "  handed:     ${told:- nothing beyond the document}"

if [ ! -f "$specification" ]; then
  echo "No document for ${API} under /specifications. Nothing can be tested; idling so the"
  echo "run is recorded as empty rather than as a crash."
  while true; do sleep 60; done
fi

pass=0
while true; do
  pass=$((pass + 1))
  started=$(date +%s)
  echo "=== pass ${pass} begins $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

  # The budget is the whole session. RESTest spends it rather than stopping after one lap,
  # so a pass normally lasts until the platform stops the container; the loop is what keeps
  # the container alive on the occasions a pass ends by itself.
  # $told is deliberately unquoted: it is zero to six arguments, none with a space.
  # shellcheck disable=SC2086
  /tool/restest run "$specification" \
    --url "$url" \
    --budget "${TIME_BUDGET}m" \
    --out "/tmp/restest-out/pass-${pass}" \
    $told
  status=$?

  elapsed=$(( $(date +%s) - started ))
  echo "=== pass ${pass} ended after ${elapsed}s, answering ${status} ==="

  # A pass that ends at once means RESTest could not start: a document it cannot read, an
  # address nothing answers on. Looping on that as fast as the machine allows would steal
  # the very resources the measurement is about, so slow down and keep saying why.
  if [ "$elapsed" -lt 10 ]; then
    sleep 15
  fi
done
