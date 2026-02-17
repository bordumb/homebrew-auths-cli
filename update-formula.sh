#!/usr/bin/env bash
# Helper script to update the Homebrew formula with new release checksums

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.0.1-rc.7"
    exit 1
fi

VERSION="$1"
REPO="bordumb/auths"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"

echo "Fetching SHA256 checksums for version ${VERSION}..."
echo "Release URL: ${BASE_URL}"
echo ""

# Function to extract SHA256 from .auths.json attestation or fall back to .sha256
get_checksum() {
    local artifact=$1
    local attestation_url="${BASE_URL}/${artifact}.auths.json"
    local legacy_url="${BASE_URL}/${artifact}.sha256"

    # Try to fetch .auths.json attestation first
    local attestation=$(curl -sL "$attestation_url" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$attestation" ] && echo "$attestation" | jq -e '.payload.digest.hex' > /dev/null 2>&1; then
        echo "$attestation" | jq -r '.payload.digest.hex'
        return 0
    fi

    # Fall back to legacy .sha256 file
    local sha=$(curl -sL "$legacy_url" 2>/dev/null | awk '{print $1}')
    if [ -n "$sha" ] && [ "$sha" != "Not" ]; then
        echo "$sha"
        return 0
    fi

    return 1
}

# Fetch Intel Mac checksum
X86_64_SHA=$(get_checksum "auths-macos-x86_64.tar.gz")
if [ -z "$X86_64_SHA" ]; then
    echo "Error: Failed to fetch x86_64 checksum"
    echo "Tried:"
    echo "  - ${BASE_URL}/auths-macos-x86_64.tar.gz.auths.json (attestation)"
    echo "  - ${BASE_URL}/auths-macos-x86_64.tar.gz.sha256 (legacy)"
    echo "Make sure the release exists: https://github.com/${REPO}/releases/tag/v${VERSION}"
    exit 1
fi
echo "✓ x86_64 SHA256: $X86_64_SHA"

# Fetch ARM Mac checksum
ARM64_SHA=$(get_checksum "auths-macos-aarch64.tar.gz")
if [ -z "$ARM64_SHA" ]; then
    echo "Error: Failed to fetch aarch64 checksum"
    echo "Tried:"
    echo "  - ${BASE_URL}/auths-macos-aarch64.tar.gz.auths.json (attestation)"
    echo "  - ${BASE_URL}/auths-macos-aarch64.tar.gz.sha256 (legacy)"
    echo "Make sure the release exists: https://github.com/${REPO}/releases/tag/v${VERSION}"
    exit 1
fi
echo "✓ aarch64 SHA256: $ARM64_SHA"
echo ""

# Update the formula file
FORMULA_FILE="Formula/auths.rb"
if [ ! -f "$FORMULA_FILE" ]; then
    echo "Error: $FORMULA_FILE not found"
    echo "Make sure you're running this from the homebrew-auths-cli repository root"
    exit 1
fi

# Create a backup
cp "$FORMULA_FILE" "${FORMULA_FILE}.bak"

# Update version
sed -i '' "s/version \".*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

# Update x86_64 SHA256
sed -i '' "s|sha256 \"REPLACE_WITH_ACTUAL_SHA256_FOR_X86_64\"|sha256 \"${X86_64_SHA}\"|" "$FORMULA_FILE"
sed -i '' "/Hardware::CPU.intel?/,/sha256/ s|sha256 \"[a-f0-9]*\"|sha256 \"${X86_64_SHA}\"|" "$FORMULA_FILE"

# Update ARM SHA256
sed -i '' "s|sha256 \"REPLACE_WITH_ACTUAL_SHA256_FOR_ARM64\"|sha256 \"${ARM64_SHA}\"|" "$FORMULA_FILE"
sed -i '' "/Hardware::CPU.arm?/,/sha256/ s|sha256 \"[a-f0-9]*\"|sha256 \"${ARM64_SHA}\"|" "$FORMULA_FILE"

echo "✓ Formula updated successfully!"
echo "Backup saved as ${FORMULA_FILE}.bak"
echo ""
echo "Next steps:"
echo "1. Review the changes:"
echo "   diff ${FORMULA_FILE}.bak ${FORMULA_FILE}"
echo ""
echo "2. Test locally:"
echo "   brew audit --strict --online ${FORMULA_FILE}"
echo "   brew install --build-from-source ./${FORMULA_FILE}"
echo "   brew test auths"
echo ""
echo "3. Commit and push:"
echo "   git add ${FORMULA_FILE}"
echo "   git commit -m \"Update auths to v${VERSION}\""
echo "   git push origin main"
