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
    tok = Pathname.glob(buildpath/"**/bin/token9").first
    app = Pathname.glob(buildpath/"**/Token9.app").first
    odie "token9 binary not found in archive" unless tok

    bin.install tok
    cp_r app, prefix/"Token9.app" if app
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

    plist = prefix/"homebrew.mxcl.token9.plist"
    app   = prefix/"Token9.app"
    home  = Pathname.new(ENV["HOME"])

    # Drop plist into LaunchAgents — auto-loads on next login.
    if plist.exist?
      dest = home/"Library"/"LaunchAgents"/"homebrew.mxcl.token9.plist"
      dest.dirname.mkpath
      cp plist, dest
    end

    # Drop app into ~/Applications.
    if app.directory?
      dest = home/"Applications"/"Token9.app"
      rm_rf dest
      cp_r app, dest
    end
  end

  def caveats
    <<~EOS
      Start now (or restart your Mac and it auto-starts):
        brew services start token9 && open ~/Applications/Token9.app
    EOS
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
