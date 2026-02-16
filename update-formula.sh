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

# Fetch Intel Mac checksum
X86_64_SHA=$(curl -sL "${BASE_URL}/auths-macos-x86_64.tar.gz.sha256" | awk '{print $1}')
if [ -z "$X86_64_SHA" ]; then
    echo "Error: Failed to fetch x86_64 checksum"
    exit 1
fi
echo "x86_64 SHA256: $X86_64_SHA"

# Fetch ARM Mac checksum
ARM64_SHA=$(curl -sL "${BASE_URL}/auths-macos-aarch64.tar.gz.sha256" | awk '{print $1}')
if [ -z "$ARM64_SHA" ]; then
    echo "Error: Failed to fetch aarch64 checksum"
    exit 1
fi
echo "aarch64 SHA256: $ARM64_SHA"

# Update the formula file
FORMULA_FILE="auths.rb"
if [ ! -f "$FORMULA_FILE" ]; then
    echo "Error: $FORMULA_FILE not found"
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

echo ""
echo "Formula updated successfully!"
echo "Backup saved as ${FORMULA_FILE}.bak"
echo ""
echo "Next steps:"
echo "1. Review the changes: diff ${FORMULA_FILE}.bak ${FORMULA_FILE}"
echo "2. Test locally: brew audit --strict ${FORMULA_FILE}"
echo "3. Install and test: brew install --build-from-source ./${FORMULA_FILE}"
echo "4. Copy to tap repo: cp ${FORMULA_FILE} /path/to/homebrew-auths/Formula/"
