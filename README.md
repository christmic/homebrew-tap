# homebrew-tap

Personal Homebrew Tap for christmic projects.

## Available Formulae

### token9

Transparent LLM gateway — local API router & token meter (Rust).

```bash
brew tap christmic/tap
brew install --head token9
```

```bash
token9 --help
token9 serve
```

### telvorn

Fork of Ghostty — terminal emulator that uses platform-native UI and GPU acceleration.

```bash
brew tap christmic/tap
brew install --cask telvorn
```

## Update

```bash
brew upgrade --head token9       # rebuild token9 from latest master
brew upgrade --cask telvorn       # download latest telvorn release
```

## Uninstall

```bash
brew uninstall token9
brew uninstall --cask telvorn
brew untap christmic/tap
```

## Development

### Adding a new formula

1. Create `Formula/<name>.rb` for CLI tools, `Casks/<name>.rb` for GUI apps
2. Commit and push to master
3. Install with `brew install christmic/tap/<name>`

### Releasing a new version (stable)

1. Tag the upstream repo: `git tag vX.Y.Z && git push --tags`
2. Create a GitHub release with tarball/asset
3. Update the formula with version and sha256

## Notes

- Only supports macOS ARM64 (Apple Silicon)
- Requires macOS Ventura or later
- Token9 also requires Rust toolchain (`xcode-select --install` or `brew install rust`)
