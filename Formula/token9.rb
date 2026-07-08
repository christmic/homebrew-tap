# typed: false
# frozen_string_literal: true

class Token9 < Formula
  desc "Transparent LLM gateway — local API router & token meter"
  homepage "https://github.com/christmic/token9"
  head "https://github.com/christmic/token9.git", branch: "master"

  depends_on "rust" => :build
  depends_on macos: :ventura

  def install
    # 1. Build the Rust server binary (`token9 serve`).
    system "cargo", "install", "--root", prefix, "--path", "token9-server"

    # 2. Build the SwiftUI menu-bar app and assemble Token9.app into the keg.
    cd "token9-apps/macos" do
      system "swift", "build", "-c", "release"
      bin_path = `swift build -c release --show-bin-path`.strip
      bundle = prefix/"Token9.app"
      rm_rf bundle
      (bundle/"Contents/MacOS").mkpath
      cp "#{bin_path}/Token9", bundle/"Contents/MacOS/Token9"
      (bundle/"Contents/Info.plist").write <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleExecutable</key><string>Token9</string>
          <key>CFBundleIdentifier</key><string>ai.oraculo.token9</string>
          <key>CFBundleName</key><string>token9</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>0.1.0</string>
          <key>LSMinimumSystemVersion</key><string>14.0</string>
          <key>NSHighResolutionCapable</key><true/>
          <key>LSUIElement</key><true/>
        </dict>
        </plist>
      PLIST
    end
  end

  service do
    run [opt_bin/"token9", "serve"]
    keep_alive true
    run_at_load true
    log_path var/"log/token9.log"
    error_log_path var/"log/token9.err.log"
  end

  def post_install
    (var/"log").mkpath

    # Install the menu-bar app to ~/Applications so the user can launch it.
    apps_dir = Pathname.new(Dir.home)/"Applications"
    apps_dir.mkpath
    app_src = prefix/"Token9.app"
    app_dst = apps_dir/"Token9.app"
    rm_rf app_dst
    cp_r app_src, app_dst

    ohai "Token9.app installed at #{app_dst}"
    ohai "Starting token9 as a launchd service..."
    system "brew", "services", "start", "token9"
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
