# Credential and secret policy

## Never commit

- API keys, tokens, passwords, SSH private keys, certificates, recovery codes,
  cookies, browser data, or credential exports.
- Real `.env` files or machine-specific inventory and diagnostic output.

## Safe local storage

Use Windows Credential Manager, the SSH key files under the user's `.ssh`
folder, an ignored local `.env` file, or the connected tool's secret store.
Only public keys may be shared when needed for setup.

## Before every commit

1. Inspect `git status --short` and the staged diff.
2. Ensure ignored local files were not force-added.
3. Run `git diff --check` and a secret-marker scan.
4. Stop and remove any sensitive value before committing.

## If a secret is exposed

Treat it as compromised: revoke or rotate it at the provider immediately, then
remove it from the working tree and publish a corrective commit. Do not paste
the secret into chat while investigating.
