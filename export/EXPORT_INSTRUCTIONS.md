MERLIN snapshot export - instructions

This branch (export/snapshot-2026-09-04) contains helper artifacts and a script to create a signed, verifiable snapshot of the repository for archival.

Files included (in this branch):
 - make_snapshot.sh       : script to create tarball, checksums, manifest, and create signatures
 - manifest.template.json : template manifest with placeholders
 - SHA256SUMS.placeholder : placeholder that will be replaced when running the script
 - SIGNING_README.md      : short instructions for signing and verification

Quick steps to produce the signed archive locally
1) Clone your repo (if not already):
   git clone https://github.com/unityinix-ai/MERLIN.git
   cd MERLIN

2) Check out the export branch we created:
   git fetch origin
   git checkout export/snapshot-2026-09-04

3) Run the snapshot script (requires git, sha256sum, stat, jq optional, gpg optional):
   chmod +x export/make_snapshot.sh
   ./export/make_snapshot.sh

   This will create:
    - MERLIN-2026-09-04-<shortsha>.tar.gz
    - SHA256SUMS
    - manifest.json
    - manifest.json.asc (if gpg is available and you have signing key)
    - SHA256SUMS.asc (optional)

4) Verify the tarball locally:
   sha256sum -c SHA256SUMS

5) Sign (if you did not sign locally with gpg):
   gpg --armor --detach-sign -o manifest.json.asc manifest.json
   gpg --armor --detach-sign -o SHA256SUMS.asc SHA256SUMS

6) Publish artifacts (recommended minimum):
   - Create a GitHub Release on the repository for tag export/snapshot-2026-09-04 and attach the tarball, manifest.json, SHA256SUMS and signature files.
   - Optionally upload the same artifacts to Internet Archive and/or Zenodo for long-term archiving and DOI creation.

Verification guidance for consumers
 - To verify checksums: sha256sum -c SHA256SUMS
 - To verify GPG signatures (after importing the publisher's public key): gpg --verify manifest.json.asc manifest.json

If you want me to attempt uploads, provide tokens for the target service(s). If you prefer to sign yourself, sign manifest.json.asc and SHA256SUMS.asc locally and then create the GitHub release.
