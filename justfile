# Default: list available recipes
default:
    @just --list

# Fetch checksums from a GitHub release and patch Formula/auths.rb in place.
# Tries the auths attestation JSON first, falls back to the .sha256 file.
# Usage: just update 0.0.1-rc.10
update VERSION:
    #!/usr/bin/env bash
    set -euo pipefail

    VERSION="{{VERSION}}"
    BASE="https://github.com/bordumb/auths-releases/releases/download/v${VERSION}"
    FORMULA="Formula/auths.rb"

    if [ ! -f "$FORMULA" ]; then
      echo "error: $FORMULA not found — run from repo root" >&2
      exit 1
    fi

    # Fetch SHA256 for one artifact.
    # Tries the .sha256 sidecar first; falls back to the auths attestation JSON.
    # Uses -sL (no -f) so HTTP errors don't kill the script — we validate the
    # output shape instead (a sha256 is exactly 64 lowercase hex characters).
    is_sha256() { [[ "$1" =~ ^[0-9a-f]{64}$ ]]; }

    get_sha() {
      local artifact="$1"
      local sha

      # Primary: .sha256 sidecar (one line: "<hex>  <filename>")
      sha=$(curl -sL "${BASE}/${artifact}.sha256" 2>/dev/null | awk '{print $1}' || true)
      is_sha256 "$sha" && { echo "$sha"; return 0; }

      # Fallback: auths attestation JSON
      sha=$(curl -sL "${BASE}/${artifact}.auths.json" 2>/dev/null \
            | jq -r '.payload.digest.hex // empty' 2>/dev/null || true)
      is_sha256 "$sha" && { echo "$sha"; return 0; }

      echo "error: could not fetch checksum for ${artifact}" >&2
      return 1
    }

    # Released targets: macOS ARM, Linux x86_64, Linux ARM (no macOS Intel build).
    echo "Fetching checksums for v${VERSION}..."
    MAC_ARM=$(get_sha "auths-macos-aarch64.tar.gz")
    LX_X86=$(get_sha  "auths-linux-x86_64.tar.gz")
    LX_ARM=$(get_sha  "auths-linux-aarch64.tar.gz")
    echo "  macOS aarch64: $MAC_ARM"
    echo "  Linux x86_64:  $LX_X86"
    echo "  Linux aarch64: $LX_ARM"

    # Patch version.
    sed -i '' "s/version \".*\"/version \"${VERSION}\"/" "$FORMULA"

    # Patch each sha256 in document order by tracking which url line was seen last.
    # awk is used instead of sed so we can match url context without fragile ranges.
    awk \
      -v mac_arm="$MAC_ARM" \
      -v lx_x86="$LX_X86"  \
      -v lx_arm="$LX_ARM"  \
    '
    /auths-macos-aarch64/ { next_sha = mac_arm }
    /auths-linux-x86_64/  { next_sha = lx_x86  }
    /auths-linux-aarch64/ { next_sha = lx_arm  }
    /sha256 "/ && next_sha != "" {
      sub(/sha256 "[^"]*"/, "sha256 \"" next_sha "\"")
      next_sha = ""
    }
    { print }
    ' "$FORMULA" > "${FORMULA}.tmp" && mv "${FORMULA}.tmp" "$FORMULA"

    echo "Formula updated: $FORMULA"

# Audit the formula (same check CI runs).
audit:
    brew audit --strict --online bordumb/auths-cli/auths

# Install from local formula, smoke-test, then uninstall.
test: audit
    brew install --build-from-source ./Formula/auths.rb
    auths --version
    auths-sign --version
    brew test auths
    brew uninstall auths

# Update formula, audit, commit, and push — for manual releases.
# Usage: just release 0.0.1-rc.10
release VERSION: (update VERSION) audit
    git add Formula/auths.rb
    git commit -m "Update auths to v{{VERSION}}"
    git push origin main
