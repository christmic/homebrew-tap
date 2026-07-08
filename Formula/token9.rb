# typed: false
# frozen_string_literal: true

class Token9 < Formula
  desc "Transparent LLM gateway — local API router & token meter"
  homepage "https://github.com/christmic/token9"
  head "https://github.com/christmic/token9.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "token9-server"
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
    ohai "Registering token9 as a launchd service..."
    system "brew", "services", "start", "token9"
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
