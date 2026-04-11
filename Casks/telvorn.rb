cask "telvorn" do
  version "0.0.1"
  sha256 "需要替换为实际sha256"

  url "https://github.com/christmic/telvorn/releases/download/v#{version}/telvorn-macos-arm64.dmg"
  name "Telvorn"
  desc "Fork of Ghostty - Terminal emulator that uses platform-native UI and GPU acceleration"
  homepage "https://github.com/christmic/telvorn/"

  depends_on macos: ">= :ventura"

  app "Telvorn.app"

  zap trash: [
    "~/.config/telvorn",
    "~/Library/Application Support/com.christmic.telvorn",
    "~/Library/Caches/com.christmic.telvorn",
    "~/Library/Preferences/com.christmic.telvorn.plist",
  ]
end
