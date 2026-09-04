#!/usr/bin/env bash
set -euo pipefail

# make_snapshot.sh
# Run from a local clone of unityinix-ai/MERLIN or on a machine with git access to the repo.
# This script creates a tarball snapshot at the specified commit, computes checksums,
# produces a manifest.json, and (optionally) creates detached GPG signatures.

COMMIT="46109051f5ef490bd3c133584a5d60d87fc758a0"
BRANCH="export/snapshot-2026-09-04"
TARBALL="MERLIN-2026-09-04-${COMMIT:0:7}.tar.gz"

echo "Creating tarball $TARBALL from commit $COMMIT"
# Use git archive to make an exact snapshot of the tree at the commit
git archive --format=tar.gz -o "$TARBALL" "$COMMIT"

echo "Computing SHA256 checksum"
sha256sum "$TARBALL" > SHA256SUMS

echo "Creating manifest.json (template)"
cat > manifest.json <<'EOF'
{
  "repo": "unityinix-ai/MERLIN",
  "owner": "unityinix-ai",
  "branch": "export/snapshot-2026-09-04",
  "commit": "46109051f5ef490bd3c133584a5d60d87fc758a0",
  "tarball": "MERLIN-2026-09-04-4610905.tar.gz",
  "tarball_sha256": "__REPLACE_WITH_VALUE__",
  "tarball_size_bytes": __REPLACE_WITH_VALUE__,
  "created_at": "__REPLACE_WITH_VALUE__",
  "tree_sha": "c2997e3fcec2a7c7328ff1a30bb9e924506cc929"
}
EOF

sha256=$(cut -d' ' -f1 SHA256SUMS)
size=$(stat -c%s "$TARBALL")
now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update manifest.json with computed values using jq (require jq)
if command -v jq >/dev/null 2>&1; then
  jq --arg sha "$sha256" --argjson size "$size" --arg now "$now" \
     '.tarball_sha256 = $sha | .tarball_size_bytes = $size | .created_at = $now' manifest.json \
     > manifest.tmp && mv manifest.tmp manifest.json
else
  echo "Warning: jq not found. manifest.json left with placeholders. Install jq to auto-fill manifest."
fi

# Create detached ASCII-armored signatures if gpg available
if command -v gpg >/dev/null 2>&1; then
  echo "Creating detached signatures (manifest.json.asc, SHA256SUMS.asc) using gpg"
  gpg --armor --output manifest.json.asc --detach-sign manifest.json
  gpg --armor --output SHA256SUMS.asc --detach-sign SHA256SUMS
else
  echo "gpg not found. To create signatures locally run:"
  echo "  gpg --armor --detach-sign -o manifest.json.asc manifest.json"
  echo "  gpg --armor --detach-sign -o SHA256SUMS.asc SHA256SUMS"
fi

cat <<MSG

Snapshot complete.
Files produced:
 - $TARBALL
 - SHA256SUMS
 - manifest.json
 - (optional) manifest.json.asc
 - (optional) SHA256SUMS.asc

Next steps (recommended):
 - Verify the tarball locally: sha256sum -c SHA256SUMS
 - If you created signatures, publish the public key fingerprint and the .asc files with the artifacts.
 - Create a GitHub Release and attach the tarball, SHA256SUMS, manifest.json and signature files.
 - Archive to Zenodo/Internet Archive for long-term storage.
MSG
