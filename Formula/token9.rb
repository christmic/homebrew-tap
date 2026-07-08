# typed: false
# frozen_string_literal: true

class Token9 < Formula
  desc "Transparent LLM gateway — local API router & token meter"
  homepage "https://github.com/christmic/token9"
  version "0.1.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/christmic/token9/releases/download/v#{version}/token9-v#{version}-macos-arm64.tar.gz"
      sha256 "REPLACE_ARM64_SHA256"
    else
      odie "token9 only ships macOS arm64 builds"
    end
  end

  on_linux do
    odie "token9 currently ships macOS arm64 only"
  end

  depends_on macos: :ventura

  def install
    # Tarball layout: token9-<os>-<arch>/{bin/token9, Token9.app/}
    pkg = buildpath.glob("token9-*-*").first
    bin.install pkg/"bin/token9"

    if OS.mac?
      app_src = pkg/"Token9.app"
      (prefix/"Token9.app").install app_src.children
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

    if OS.mac?
      apps_dir = Pathname.new(Dir.home)/"Applications"
      apps_dir.mkpath
      app_dst = apps_dir/"Token9.app"
      rm_rf app_dst
      cp_r "#{prefix}/Token9.app", app_dst
      ohai "Token9.app installed at #{app_dst}"
    end

    ohai "Starting token9 as a launchd service..."
    system "brew", "services", "start", "token9"
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
