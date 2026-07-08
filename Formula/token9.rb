# typed: false
# frozen_string_literal: true

class Token9 < Formula
  desc "Transparent LLM gateway — local API router & token meter"
  homepage "https://github.com/christmic/token9"
  version "0.1.5"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/christmic/token9/releases/download/v#{version}/token9-v#{version}-macos-arm64.tar.gz"
      sha256 "c34abfc962ee225c51dbb78ab7a43e35e564b42a3694983fe4e58d0f3396bdfa"
    else
      odie "token9 only ships macOS arm64 builds"
    end
  end

  on_linux do
    odie "token9 currently ships macOS arm64 only"
  end

  depends_on macos: :ventura

  def user_home
    require "etc"
    Etc.getpwuid.dir
  rescue
    ENV.fetch("HOME", Dir.home)
  end

  def install
    pkg = buildpath/"token9-macos-arm64"
    bin.install pkg/"bin/token9"
    cp_r pkg/"Token9.app", prefix/"Token9.app" if (pkg/"Token9.app").directory?
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
    home = Pathname.new(user_home)

    # 1. Install + load launchd plist directly (no brew services — avoids tap trust in subprocess)
    plist_src = prefix/"homebrew.mxcl.token9.plist"
    plist_dst = home/".local/share/launchd"/"ai.oraculo.token9.plist"
    if plist_src.exist?
      plist_dst.dirname.mkpath
      cp plist_src, plist_dst
      # bootstrap into the user's GUI domain so it survives logout
      uid = Etc.getpwuid.uid
      system "launchctl", "bootout", "gui/#{uid}/ai.oraculo.token9", exception: false
      system "launchctl", "bootstrap", "gui/#{uid}", plist_dst.to_s
      ohai "token9 service registered (launchd) — auto-starts on login"
    end

    # 2. Copy Token9.app to ~/Applications
    app_src = prefix/"Token9.app"
    if app_src.directory?
      app_dst = home/"Applications"/"Token9.app"
      rm_rf app_dst
      cp_r app_src, app_dst
      ohai "Token9.app copied to #{app_dst}"
    end

    # 3. Open the dashboard immediately
    if app_src.directory?
      system "open", (home/"Applications"/"Token9.app").to_s, exception: false
    end
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
