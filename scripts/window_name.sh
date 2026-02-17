#!/usr/bin/env bash

set -u

pane_pid="${1:-}"
pane_path="${2:-}"

basename_or_root() {
  local path="$1"
  local base

  if [[ -z "$path" ]]; then
    printf 'shell\n'
    return
  fi

  base="${path%/}"
  base="${base##*/}"
  if [[ -z "$base" ]]; then
    printf '/\n'
    return
  fi

  printf '%s\n' "$base"
}

extract_ssh_host() {
  local ssh_cmd="$1"
  local -a args
  local token dest="" skip_next=0 i

  read -r -a args <<<"$ssh_cmd"
  if (( ${#args[@]} == 0 )); then
    return 1
  fi

  for ((i = 1; i < ${#args[@]}; i++)); do
    token="${args[$i]}"

    if (( skip_next )); then
      skip_next=0
      continue
    fi

    case "$token" in
      --)
        if (( i + 1 < ${#args[@]} )); then
          dest="${args[$((i + 1))]}"
        fi
        break
        ;;
      -[bBcDEeFIiJLlmoOpQRSwW])
        skip_next=1
        continue
        ;;
      -p)
        skip_next=1
        continue
        ;;
      -i*|-o*|-J*|-L*|-R*|-D*|-W*|-l*|-p[0-9]*)
        continue
        ;;
      -[46AaCfGgKkMNnqsTtVvXxYy])
        continue
        ;;
      -*)
        continue
        ;;
      *)
        dest="$token"
        break
        ;;
    esac
  done

  if [[ -z "$dest" ]]; then
    return 1
  fi

  dest="${dest##*@}"

  if [[ "$dest" =~ ^\[([^]]+)\](:[0-9]+)?$ ]]; then
    dest="${BASH_REMATCH[1]}"
  fi

  if [[ -n "$dest" ]]; then
    printf '%s\n' "$dest"
    return 0
  fi

  return 1
}

default_name="$(basename_or_root "$pane_path")"

if [[ -z "$pane_pid" ]]; then
  printf '%s\n' "$default_name"
  exit 0
fi

ssh_cmd=""
fg_pgid="$(ps -o tpgid= -p "$pane_pid" 2>/dev/null | tr -d '[:space:]')"
if [[ -n "$fg_pgid" && "$fg_pgid" != "-1" && "$fg_pgid" != "0" ]]; then
  ssh_cmd="$(ps -o args= -g "$fg_pgid" 2>/dev/null | awk '/(^|[[:space:]])ssh([[:space:]]|$)/ { print; exit }')"
fi

if [[ -z "$ssh_cmd" ]]; then
  ssh_cmd="$(ps -o args= -p "$pane_pid" 2>/dev/null | awk '/(^|[[:space:]])ssh([[:space:]]|$)/ { print; exit }')"
fi

if [[ -z "$ssh_cmd" ]]; then
  ssh_cmd="$(
    ps -ax -o ppid= -o args= 2>/dev/null \
      | awk -v parent="$pane_pid" '
          $1 == parent {
            $1 = ""
            sub(/^[[:space:]]+/, "", $0)
            if ($0 ~ /(^|[[:space:]])ssh([[:space:]]|$)/) {
              print
              exit
            }
          }
        '
  )"
fi

if [[ -n "$ssh_cmd" ]]; then
  if host="$(extract_ssh_host "$ssh_cmd")"; then
    printf '%s\n' "$host"
    exit 0
  fi
fi

printf '%s\n' "$default_name"
