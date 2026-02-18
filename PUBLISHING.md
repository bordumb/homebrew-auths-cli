# Publishing

## Every release (automated)

Formula updates happen automatically when a new tag is pushed to `bordumb/auths`.
The auto-update workflow fetches checksums, updates `Formula/auths.rb`, and opens a PR.
No action needed.

---

## Manual update

If you need to cut a formula update by hand:

```sh
just release 0.0.1-rc.9
```

That fetches checksums from the GitHub release, audits the formula, and pushes to main.

To test locally before committing:

```sh
just test
```

---

## What the automation does

`.github/workflows/auto-update-workflow.yml`:

1. Receives a `repository_dispatch: new-release` event from `bordumb/auths`
2. Fetches checksums from the release (attestation JSON or `.sha256` fallback)
3. Updates `Formula/auths.rb` with the new version and checksums
4. Audits and tests the formula
5. Opens a PR for review

---

## Prerequisites

- [`just`](https://github.com/casey/just) installed (`brew install just`)
- Push access to this repo
