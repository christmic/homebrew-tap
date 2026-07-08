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

  def install
    # Find the binary and app bundle wherever they are in the tarball
    # (avoids being fragile about archive nesting depth).
    tok = Pathname.glob(buildpath/"**/bin/token9").first
    app = Pathname.glob(buildpath/"**/Token9.app").first

    bin.install tok

    if OS.mac? && app
      cp_r app, prefix/"Token9.app"
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
    system({"HOMEBREW_NO_REQUIRE_TAP_TRUST" => "1"},
           "brew", "services", "start", "token9") rescue nil

    if OS.mac?
      ohai "Launching Token9.app..."
      system "open", "#{ENV["HOME"]}/Applications/Token9.app"
    end
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
