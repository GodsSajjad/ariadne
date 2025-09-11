#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'; set -f; LC_ALL=C
trap 'printf "ERROR: line %s exit %s\n" "$LINENO" "$?" >&2' ERR
# [[ "${DEBUG:-}" == "1" ]] && set -x # Disabled for production runs

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
  checked "$lcfile" "macos"   && OS="macos-14"
  checked "$lcfile" "windows" && OS="windows-latest"
  checked "$lcfile" "ubuntu"  && OS="ubuntu-latest"

  local TUNNEL="cloudflare"
  checked "$lcfile" "cloudflare"    && TUNNEL="cloudflare"
  checked "$lcfile" "localhost.run" && TUNNEL="localhostrun"
  checked "$lcfile" "ngrok"         && TUNNEL="ngrok"
  checked "$lcfile" "tailscale"     && TUNNEL="tailscale"
  checked "$lcfile" "tor"           && TUNNEL="tor"
  checked "$lcfile" "tunnelmol"     && TUNNEL="tunnelmole"

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

# Pipe stdin to the main function which will produce key=value output
parse_issue_body
