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

  def caveats
    <<~EOS
      Start the gateway:
        brew services start token9

      Open the dashboard:
        open #{opt_prefix}/Token9.app

      (Optional) Pin to /Applications:
        ln -s #{opt_prefix}/Token9.app /Applications/Token9.app
    EOS
  end

  test do
    assert_match "token9", shell_output("#{bin}/token9 --help")
  end
end
