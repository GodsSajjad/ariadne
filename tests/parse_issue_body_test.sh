#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'; set -f; LC_ALL=C
trap 'printf "ERROR: line %s exit %s\n" "$LINENO" "$?" >&2' ERR
[[ "${DEBUG:-}" == "1" ]] && set -x

DEFAULT_PORT="${DEFAULT_PORT:-8080}"
DEFAULT_MINUTES="${DEFAULT_MINUTES:-40}"
MAX_CAP_MINUTES="${MAX_CAP_MINUTES:-80}"

# --- helpers ---
esc() { printf '%s' "$1" | sed -E 's/[][(){}.^$|*+?\\]/\\&/g'; }

extract_yaml_block() { # stdin=markdown → first fenced ```yaml block
  awk '
    /^[[:space:]]*```[Yy][Aa][Mm][Ll]/ { in_block = 1; next }
    in_block {
      if (index($0, "```") > 0) {
        print substr($0, 1, index($0, "```") - 1)
        exit
      }
      print
    }
  '
}

# --- FIX 1: Made awk script more portable ---
# Switched from a gawk-specific match() to a more universal approach
# using index() and substr() to separate keys and values.
yaml_to_kv() { # stdin=yaml → key=value (top-level scalars)
  awk '
    BEGIN{FS=":"}
    /^[[:space:]]*#/ || /^[[:space:]]*$/ {next}
    {
        line=$0
        sub(/[[:space:]]+#.*$/, "", line) # strip trailing comment
        if (index(line, ":")) {
            key = substr(line, 1, index(line, ":") - 1)
            val = substr(line, index(line, ":") + 1)

            gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
            gsub(/^["'"'"']|["'"'"']$/, "", val)

            if (key ~ /^[A-Za-z0-9_.-]+$/) {
                printf("%s=%s\n", tolower(key), val)
            }
        }
    }'
}

# --- FIX 2: Made checked() regex more flexible ---
# Changed the regex to match list items starting with either '*' or '-'.
checked() { # $1=lc-file, $2=needle (substring is fine)
  local lcfile="$1" needle re
  needle="$(esc "$2")"
  re="^[[:space:]]*[*-][[:space:]]*\\[[xX]\\][[:space:]]*.*${needle}"
  grep -qiE "$re" "$lcfile"
}

parse_issue_body() { # stdin markdown → stdout key=value
  local body lcfile yaml
  body="$(mktemp)"; lcfile="${body}.lc"
  sed -E 's/<!--[^>]*-->//g' | tr -d '\r' >"$body"
  awk '{print tolower($0)}' "$body" >"$lcfile"

  # checkboxes → toggles
  local ON="false"
  checked "$lcfile" "on" && ON="true"

  local OS="ubuntu-latest"
  # NOTE: The logic here assumes only one OS/Tunnel is checked.
  # If multiple are checked, the last one found wins.
  checked "$lcfile" "macos"   && OS="macos-14"
  checked "$lcfile" "windows" && OS="windows-latest"
  checked "$lcfile" "ubuntu"  && OS="ubuntu-latest"

  local TUNNEL="cloudflare"
  checked "$lcfile" "localhost.run" && TUNNEL="localhostrun"
  checked "$lcfile" "inlets pro"    && TUNNEL="inlets"
  checked "$lcfile" "tailscale"     && TUNNEL="tailscale"
  checked "$lcfile" "tor"           && TUNNEL="tor"
  checked "$lcfile" "cloudflare"    && TUNNEL="cloudflare"

  # yaml → everything else
  yaml="$(extract_yaml_block <"$body" || true)"
  local PORT="$DEFAULT_PORT" MINUTES="$DEFAULT_MINUTES"
  if [[ -n "${yaml//[[:space:]]/}" ]]; then
    declare -A Y=()
    while IFS= read -r line; do
      k="${line%%=*}"; v="${line#*=}"
      [[ -n "$k" ]] && Y["$k"]="$v"
    done < <(printf '%s' "$yaml" | yaml_to_kv)
    [[ -n "${Y[port]:-}"    ]] && PORT="${Y[port]}"
    [[ -n "${Y[minutes]:-}" ]] && MINUTES="${Y[minutes]}"
  fi

  # validate & cap
  [[ "$PORT" =~ ^[0-9]{1,5}$ ]] || PORT="$DEFAULT_PORT"
  (( PORT>=1 && PORT<=65535 )) || PORT="$DEFAULT_PORT"
  [[ "$MINUTES" =~ ^[0-9]{1,3}$ ]] || MINUTES="$DEFAULT_MINUTES"
  (( MINUTES>=1 )) || MINUTES="$DEFAULT_MINUTES"
  (( MINUTES>MAX_CAP_MINUTES )) && MINUTES="$MAX_CAP_MINUTES" || true

  printf 'on=%s\n' "$ON"
  printf 'os=%s\n' "$OS"
  printf 'tunnel=%s\n' "$TUNNEL"
  printf 'port=%s\n' "$PORT"
  printf 'minutes=%s\n' "$MINUTES"

  rm -f "$body" "$lcfile"
}

# --- tests ---
TEMPLATE=$(cat <<'MD'
## 1. Runner OS (pick ONE)
- [x] Ubuntu (ubuntu-latest)
- [ ] macOS (macos-14)
- [ ] Windows (windows-latest)

## 2. Tunnel (pick ONE)
- [x] Cloudflare Tunnel
- [ ] localhost.run
- [ ] Inlets PRO
- [ ] Tailscale
- [ ] Tor

## 3. Power
- [x] ON  (toggle on/off)

## Config (YAML for everything else)
```yaml
port: 8080
minutes: 40````

MD
)

ALT1=$(cat <<'MD'

* [ ] Ubuntu
* [x] macos
* [ ] windows
* [x] localhost.run
* [ ] cloudflare tunnel
* [ ] tor
* [ ] ON

```yaml
port: 9090
minutes: 5
```

MD
)

ALT2=$(cat <<'MD'

* [ ] ubuntu
* [x] windows
* [ ] macos
* [ ] cloudflare tunnel
* [ ] localhost.run
* [x] tor
* [x] ON

```yaml
port: 7000
minutes: 120
```

MD
)

run_case() {
local name="$1" body="$2" want_on="$3" want_os="$4" want_tunnel="$5" want_port="$6" want_minutes="$7"
printf '\n=== CASE: %s ===\n' "$name"
mapfile -t kv < <(printf '%s' "$body" | parse_issue_body)
declare -A m=(); for line in "${kv[@]}"; do k="${line%%=*}"; v="${line#*=}"; m["$k"]="$v"; done
printf 'parsed: on=%s os=%s tunnel=%s port=%s minutes=%s\n' "${m[on]}" "${m[os]}" "${m[tunnel]}" "${m[port]}" "${m[minutes]}"
[[ "${m[on]}"      == "$want_on"     ]] || { echo "want on=$want_on"; exit 1; }
[[ "${m[os]}"      == "$want_os"     ]] || { echo "want os=$want_os"; exit 1; }
[[ "${m[tunnel]}"  == "$want_tunnel" ]] || { echo "want tunnel=$want_tunnel"; exit 1; }
[[ "${m[port]}"    == "$want_port"   ]] || { echo "want port=$want_port"; exit 1; }
[[ "${m[minutes]}" == "$want_minutes" ]] || { echo "want minutes=$want_minutes"; exit 1; }
echo "ok"
}

run_case "Ubuntu + Cloudflare + ON (yaml port/minutes)" "$TEMPLATE" "true" "ubuntu-latest" "cloudflare" "8080" "40"
run_case "macOS + lhr + OFF"                             "$ALT1"     "false" "macos-14" "localhostrun" "9090" "5"
run_case "Windows + Tor + ON (cap minutes)"              "$ALT2"     "true"  "windows-latest" "tor" "7000" "80"

echo; echo "All tests passed."
