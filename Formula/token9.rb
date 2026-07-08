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
    # Homebrew post_install may run with $HOME pointing to a temp dir;
    # resolve the real user home from the password database.
    require "etc"
    Etc.getpwuid.dir
  rescue
    ENV.fetch("HOME", Dir.home)
  end

  def install
    # Tarball layout: token9-macos-arm64/{bin/token9, Token9.app/}
    pkg = buildpath/"token9-macos-arm64"

    bin.install pkg/"bin/token9"

    if OS.mac? && (pkg/"Token9.app").directory?
      cp_r pkg/"Token9.app", prefix/"Token9.app"
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

    # Copy Token9.app to ~/Applications so the user can find it in Launchpad.
    if OS.mac?
      apps_dir = Pathname.new(user_home)/"Applications"
      apps_dir.mkpath
      app_dst = apps_dir/"Token9.app"
      rm_rf app_dst
      cp_r prefix/"Token9.app", app_dst
      ohai "Token9.app copied to #{app_dst}"
    end

    # Register + start the launchd service.
    # HOMEBREW_NO_REQUIRE_TAP_TRUST avoids trust errors in the subprocess.
    # rescue nil ensures the rest of post_install (app launch) runs even if
    # services fails (e.g. for already-running scenarios).
    ohai "Registering token9 as a launchd service..."
    system({"HOMEBREW_NO_REQUIRE_TAP_TRUST" => "1"},
           "brew", "services", "start", "token9") rescue nil

    # Pop the app open so the user sees the dashboard immediately.
    if OS.mac?
      ohai "Launching Token9.app..."
      system "open", "#{user_home}/Applications/Token9.app" rescue nil
    end
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
