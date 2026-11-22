#!/bin/bash
set -euo pipefail

# scripts/retry.sh - Execute a command or installation script with automatic retry and backoff

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MAX_ATTEMPTS="${RETRY_ATTEMPTS:-3}"
DELAY_SECONDS="${RETRY_DELAY:-2}"

show_help() {
  cat << EOF
Usage: ./scripts/retry.sh [OPTIONS] [--] <COMMAND_OR_SCRIPT> [ARGS...]

Executes an installation script or command and automatically retries on failure.

Options:
  -n, --attempts <N>   Maximum number of attempts (default: $MAX_ATTEMPTS, or RETRY_ATTEMPTS)
  -d, --delay <SEC>    Base delay in seconds between retries (default: $DELAY_SECONDS, or RETRY_DELAY)
  -h, --help           Show this help message

Examples:
  ./scripts/retry.sh ./install.sh
  ./scripts/retry.sh ./scripts/core/docker.sh
  ./scripts/retry.sh -n 5 -d 3 sudo apt-get install -y curl
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--attempts)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}[ERROR]${NC} Missing argument for $1" >&2
        exit 1
      fi
      MAX_ATTEMPTS="$2"
      shift 2
      ;;
    -d|--delay)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}[ERROR]${NC} Missing argument for $1" >&2
        exit 1
      fi
      DELAY_SECONDS="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo -e "${RED}[ERROR]${NC} Unknown option: $1" >&2
      show_help
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -eq 0 ]]; then
  show_help
  exit 1
fi

if ! [[ "$MAX_ATTEMPTS" =~ ^[1-9][0-9]*$ ]]; then
  echo -e "${RED}[ERROR]${NC} Attempts must be a positive integer (got: $MAX_ATTEMPTS)" >&2
  exit 1
fi

if ! [[ "$DELAY_SECONDS" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}[ERROR]${NC} Delay must be a non-negative integer (got: $DELAY_SECONDS)" >&2
  exit 1
fi

TARGET="$1"
shift
CMD=()

if [[ -f "$TARGET" && "$TARGET" == *.sh && ! -x "$TARGET" ]]; then
  CMD=("bash" "$TARGET" "$@")
elif [[ ! -e "$TARGET" && -f "$ROOT_DIR/$TARGET" ]]; then
  if [[ "$ROOT_DIR/$TARGET" == *.sh && ! -x "$ROOT_DIR/$TARGET" ]]; then
    CMD=("bash" "$ROOT_DIR/$TARGET" "$@")
  else
    CMD=("$ROOT_DIR/$TARGET" "$@")
  fi
else
  CMD=("$TARGET" "$@")
fi

attempt=1
while [[ $attempt -le $MAX_ATTEMPTS ]]; do
  if [[ $attempt -gt 1 ]]; then
    echo -e "${YELLOW}[RETRY]${NC} Attempt $attempt of $MAX_ATTEMPTS: ${CMD[*]}"
  else
    echo -e "${BLUE}[INFO]${NC} Running (attempt $attempt/$MAX_ATTEMPTS): ${CMD[*]}"
  fi

  set +e
  "${CMD[@]}"
  exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    if [[ $attempt -gt 1 ]]; then
      echo -e "${GREEN}[SUCCESS]${NC} Succeeded on attempt $attempt/$MAX_ATTEMPTS: ${CMD[*]}"
    fi
    exit 0
  fi

  if [[ $attempt -lt $MAX_ATTEMPTS ]]; then
    wait_time=$((DELAY_SECONDS * attempt))
    echo -e "${YELLOW}[WARN]${NC} Command failed with exit code $exit_code. Retrying in ${wait_time}s..." >&2
    sleep "$wait_time"
  fi

  attempt=$((attempt + 1))
done

echo -e "${RED}[ERROR]${NC} Command failed after $MAX_ATTEMPTS attempts (last exit code: $exit_code): ${CMD[*]}" >&2
exit "$exit_code"
