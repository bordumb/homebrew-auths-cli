# 5-Minute Quickstart

Get started with cryptographically signed Git commits using KERI-based decentralized identity.

## What You'll Learn

- Install auths CLI
- Create your cryptographic identity
- Auto-sign Git commits
- Verify commits in GitHub Actions

**Time**: ~5 minutes

---

## Step 1: Install Auths (30 seconds)

### macOS / Linux

```bash
brew tap bordumb/auths-cli
brew install auths
```

### From Source

```bash
cargo install --git https://github.com/bordumb/auths.git auths_cli
```

Verify installation:

```bash
auths --version
```

---

## Step 2: Create Your Identity (60 seconds)

Initialize your cryptographic identity:

```bash
auths init
```

This will:
- Create your `did:keri` identity
- Generate an Ed25519 keypair
- Store keys securely in your system keychain
- Set up the `~/.auths` Git repository

Check your identity:

```bash
auths status
```

You'll see output like:

```
Identity: did:keri:EBf...
Key Alias: controller
Devices: 1 linked

Ready to sign commits.
```

---

## Step 3: Configure Git to Auto-Sign Commits (30 seconds)

Tell Git to use Auths for commit signing:

```bash
auths git setup
```

This configures:
- `gpg.format = ssh`
- `gpg.ssh.program = auths-sign`
- `user.signingKey = auths:<your-key-alias>`
- `commit.gpgsign = true`

All future commits will now be automatically signed!

---

## Step 4: Make a Signed Commit (30 seconds)

```bash
cd your-project/
echo "# Test" >> README.md
git add README.md
git commit -m "My first signed commit"
```

Verify the signature:

```bash
auths verify-commit HEAD
```

Output:

```
Commit abc123 is valid
  Signed by: did:keri:EBf...
  Device: did:key:z6Mk...
  Status: VALID
```

---

## Step 5: Verify Commits in GitHub Actions (2 minutes)

### 5a. Generate Allowed Signers File

Export your public key for GitHub:

```bash
auths git allowed-signers > .auths/allowed_signers
```

Commit it to your repo:

```bash
git add .auths/allowed_signers
git commit -m "Add allowed signers for commit verification"
git push
```

### 5b. Create GitHub Actions Workflow

Create `.github/workflows/verify-commits.yml`:

```yaml
name: Verify Commits

on:
  pull_request:
  push:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: bordumb/auths-verify-action@v1
        with:
          allowed-signers: '.auths/allowed_signers'
```

Commit and push:

```bash
git add .github/workflows/verify-commits.yml
git commit -m "Add commit verification workflow"
git push
```

### 5c. Watch It Work

Open a pull request or push to `main`. The GitHub Action will:
- ✅ Verify all commits are signed
- ✅ Check signatures against allowed signers
- ✅ Display results in PR checks

---

## What's Next?

### Link Multiple Devices

Work from laptop and desktop? Link them to the same identity:

```bash
# On your second device
auths device link --device-did did:key:z6Mk...
```

### Revoke a Compromised Device

Lost your laptop?

```bash
auths device revoke --device-did did:key:z6Mk...
```

### Learn More

- [Auths Documentation](https://github.com/bordumb/auths)
- [GitHub Action for Verification](https://github.com/marketplace/actions/auths-verify-commits)
- [Full Setup Guide](./SETUP_GUIDE.md)

---

## Troubleshooting

### "auths: command not found"

Make sure `~/.cargo/bin` is in your PATH:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

Or reinstall via Homebrew:

```bash
brew reinstall auths
```

### Passphrase Prompts Not Showing

`auths-sign` reads from `/dev/tty`. Run Git from an interactive terminal, not from a piped script or some IDEs.

### Commit Not Signed

Check Git configuration:

```bash
git config --get gpg.format
# Should output: ssh

git config --get user.signingKey
# Should output: auths:<your-key-alias>
```

Re-run setup if needed:

```bash
auths git setup
```

---

## Summary

You've learned to:

1. ✅ Install `auths` CLI via Homebrew
2. ✅ Create a cryptographic identity
3. ✅ Auto-sign Git commits
4. ✅ Verify commits in GitHub Actions

**No central server. No blockchain. Just Git and cryptography.**

For deeper dives, see:
- [Auths Repository](https://github.com/bordumb/auths)
- [Architecture Documentation](https://github.com/bordumb/auths/blob/main/ARCHITECTURE.md)
- [GitHub Action](https://github.com/marketplace/actions/auths-verify-commits)
