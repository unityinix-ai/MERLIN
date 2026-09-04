Signing placeholders and verification

Recommended signing steps (local):
1) Ensure you have a GPG key: gpg --list-secret-keys
2) Create detached ASCII-armored signatures:
   gpg --armor --detach-sign -u <your-key-id> -o manifest.json.asc manifest.json
   gpg --armor --detach-sign -u <your-key-id> -o SHA256SUMS.asc SHA256SUMS
3) Publish your public key fingerprint in the release notes and/or a well-known location so others can verify signatures.

Verification example (consumer):
 - Import the publisher's public key: gpg --recv-keys <key-id>  (or gpg --import pubkey.asc)
 - Verify manifest: gpg --verify manifest.json.asc manifest.json
 - Verify SHA256: sha256sum -c SHA256SUMS
