# Homebrew Tap for Auths

Official Homebrew tap for [Auths](https://github.com/bordumb/auths) - Git-native identity and access management.

## Installation

```sh
brew install bordumb/auths-cli/auths
```

Or tap first, then install:

```sh
brew tap bordumb/auths-cli
brew install auths
```

## What's Included

- `auths` - Main CLI for identity management
- `auths-sign` - Git commit signing tool
- `auths-verify` - Signature verification tool

## Usage

```sh
auths --version
auths init
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get the tap published in ~15 minutes
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed explanations and troubleshooting

## Updating

```sh
brew upgrade auths
```

## Maintainers

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for instructions on updating the formula for new releases.
