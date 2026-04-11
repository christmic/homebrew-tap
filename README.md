# homebrew-tap

Personal Homebrew Tap for Telvorn (Ghostty fork).

## Install

```bash
brew tap christmic/tap
brew install --cask telvorn
```

## Update

```bash
brew upgrade --cask telvorn
```

## Uninstall

```bash
brew uninstall --cask telvorn
brew untap christmic/tap
```

## Development

首次推送：
```bash
git remote add origin git@github.com:christmic/homebrew-tap.git
git push -u origin master
```

发布新版本：
1. 构建 telvorn 并打包成 `.dmg`
2. 计算 sha256：`shasum -a 256 telvorn-macos-arm64.dmg`
3. 更新 `Casks/telvorn.rb` 中的 `version` 和 `sha256`
4. 提交并推送

## Notes

- Only supports macOS ARM64 (Apple Silicon)
- Requires macOS Ventura or later
